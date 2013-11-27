package SpaceBotWar;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.030';
$VERSION = eval $VERSION;

use SpaceBotWar::WS::Root;
use SpaceBotWar::WS::Script;
use SpaceBotWar::DB;

use File::Basename 'dirname';
use File::Spec::Functions qw'rel2abs catdir';
use Cwd;

has db => sub {
    my $self = shift;

    my $schema = SpaceBotWar::DB->connect(
        $self->config->{db}{dsn},
        $self->config->{db}{username},
        $self->config->{db}{password},
        $self->config->{db}{options},
    ) or die "Could not connect to database using DSN " . $self->config->{db}{dsn};

    return $schema;
};

has home_path => sub {
    my $path = $ENV{SBW_HOME} || getcwd;
    return File::Spec->rel2abs($path);
};

has config_file => sub {
    my $self = shift;
    return $ENV{SBW_CONFIG} if $ENV{SBW_CONFIG}; 

    return rel2abs( 'spacebotwar.conf', $self->home_path );
};

# 'rooms' are where web socket things happen, be they chat or competitions
# or play-back of battles.
# 
has rooms => sub {
    my ($self) = @_;

    return SpaceBotWar::WS::Root->new({
        log     => $self->app->log,
        app     => $self->app,
    });
};

# 'scripts' are where web socket running of script code is done
#
has scripts => sub {
    my ($self) = @_;

    return SpaceBotWar::WS::Script->new({
        log     => $self->app->log,
    });
};

sub load_config {
    my ($app) = @_;

    $app->plugin( Config => { 
        file => $app->config_file,
    });

    if ( my $secret = $app->config->{secret} ) {
        $app->secret( $secret );
    }
}

sub startup {
    my ($app) = @_;

    # set home folder
    $app->home->parse( $app->home_path );

    {
        # setup logging path
        # code stolen from Mojolicious.pm
        my $mode = $app->mode;
        if (-w $app->home->rel_file('log')) {
            $app->log->path($app->home->rel_file("log/$mode.log"));
        }
    }

    $app->load_config;

    {
        my $base = catdir(dirname(rel2abs(__FILE__)), '..');
        $app->static->paths->[0] = catdir($base, 'public');
        $app->renderer->paths->[0] = catdir($base, 'templates');
    }

    # use commands from SpaceBotWar::Command namespace
    push @{$app->commands->namespaces}, 'SpaceBotWar::Command';

    ## Helpers ##

    $app->helper( schema => sub { shift->app->db } );

    $app->helper( home_page => sub{ '/page/home' } );

    $app->helper( auth_fail => sub {
        my $self = shift;
        my $message = shift || "Not Authorized";
        $self->humane_flash( $message );
        $self->redirect_to( $self->home_page );
        return 0;
    });

    $app->helper( get_user => sub {
        my ($self, $name) = @_;
        if (not $name) {
            $name = $self->session->{username};
        }
        return undef if not $name;
        return $self->schema->resultset('User')->single({name => $name});
    });

    $app->helper( is_admin => sub {
        my $self = shift;
        my $user = $self->get_user(@_);
        return undef unless $user;
        return $user->is_admin;
    });

    $app->plugin( 'Memorize' );
    $app->plugin( 'SpaceBotWar::Plugin::Modal' );

    ## Routing ##

    my $r = $app->routes;
    $r->namespaces(['SpaceBotWar::Web']);

    $r->get( '/' )->to(controller => 'page', action => 'home');
    $r->websocket( '/ws' )->to(controller => 'page', action => 'ws_home');

    $r->get( '/foo' )->to(controller => 'page', action => 'foo');
    $r->get( '/register' )->to(controller => 'page', action => 'register');

    $r->get( '/remote/game' )->to('remote#game');
    $r->get( '/server/game' )->to('server#game');
    $r->get( '/server/start_game' )->to('server#start_game');
    $r->websocket( '/server/ws_connect' )->to('server#ws_connect');
   
    $r->post( '/login' )->to('user#login');

    $r->any( '/logout' )->to('user#logout');

    my $if_admin = $r->under( sub {
        my $self = shift;

        return $self->auth_fail unless $self->is_admin;

        return 1;
    });

    $if_admin->any( '/admin/users' )->to('admin#users');
    $if_admin->any( '/admin/pages' )->to('admin#pages');
    $if_admin->any( '/admin/user/:name' )->to('admin#user');
    $if_admin->websocket( '/store/user' )->to('admin#store_user');
    $if_admin->websocket( '/remove/page' )->to('admin#remove_page');

    ## Additional Plugins ##
    $app->plugin('Humane', auto => 0);
    $app->humane->theme('jackedup');
    $app->plugin('ConsoleLogger') if $ENV{GALILEO_CONSOLE_LOGGER};
}

1;


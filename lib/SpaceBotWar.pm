package SpaceBotWar;
use Mojo::Base 'Mojolicious';

our $VERSION = '0.030';
$VERSION = eval $VERSION;

use SpaceBotWar::WS::Root;

use File::Basename 'dirname';
use File::Spec::Functions qw'rel2abs catdir';
use File::ShareDir 'dist_dir';
use Cwd;

has db => sub {
    my $self = shift;
    my $schema_class = $self->config->{db_schema} or die "Unknown DB Schema Class";
    eval "require $schema_class" or die "Could not load Schema Class ($schema_class). $@\n";

    my $schema = $schema_class->connect( 
        @{ $self->config }{ qw/db_dsn db_username db_password db_options/ }
    ) or die "Could not connect to $schema_class using DSN " . $self->config->{db_dsn};

    return $schema;
};

has home_path => sub {
    my $path = $ENV{GALILEO_HOME} || getcwd;
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
    });
};


sub load_config {
    my $app = shift;

    $app->plugin( Config => { 
        file => $app->config_file,
        default => {
            db_schema       => 'SpaceBotWar:DB::Schema',
            db_dsn          => 'dbi:SQLite:dbname=' . $app->home->rel_file( 'spacebotwar.db' ),
            db_username     => undef,
            db_password     => undef,
            db_options      => { sqlite_unicode => 1 },
            extra_css       => [ '/themes/standard.css' ],
            extra_js        => [],
            extra_static_paths  => ['static'],
            sanitize        => 1,
            secret          => '', # default to null (unset) in case I implement an iterative config helper
        },
    });

    if ( my $secret = $app->config->{secret} ) {
        $app->secret( $secret );
    }
}

sub startup {
    my $app = shift;

    # set home folder
    $app->home->parse( $app->home_path );

    {
        # setup logging path
        # code stolen from Mojolicious.pm
        my $mode = $app->mode;

        $app->log->path($app->home->rel_file("log/$mode.log"))
            if -w $app->home->rel_file('log');
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

    $app->helper( 'home_page' => sub{ '/page/home' } );

    $app->helper( 'auth_fail' => sub {
        my $self = shift;
        my $message = shift || "Not Authorized";
        $self->humane_flash( $message );
        $self->redirect_to( $self->home_page );
        return 0;
    });

    $app->helper( 'get_user' => sub {
        my ($self, $name) = @_;
        unless ($name) {
            $name = $self->session->{username};
        }
        return undef unless $name;
        return $self->schema->resultset('User')->single({name => $name});
    });

    $app->helper( 'is_author' => sub {
        my $self = shift;
        my $user = $self->get_user(@_);
        return undef unless $user;
        return $user->is_author;
    });
    $app->helper( 'is_admin' => sub {
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


    $r->get( '/remote/game' )->to('remote#game');
    $r->get( '/server/game' )->to('server#game');
    $r->get( '/server/start_game' )->to('server#start_game');
    $r->websocket( '/server/ws_connect' )->to('server#ws');
   
    $r->post( '/login' )->to('user#login');
    $r->any( '/logout' )->to('user#logout');

    my $if_author = $r->under( sub {
        my $self = shift;

        return $self->auth_fail unless $self->is_author;

        return 1;
    });

    $if_author->any( '/admin/menu' )->to('menu#edit');
    $if_author->any( '/edit/:name' )->to('web#page#edit');
    $if_author->websocket( '/store/page' )->to('web#page#store');
    $if_author->websocket( '/store/menu' )->to('menu#store');
    $if_author->websocket( '/files/list' )->to('file#list');

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
    $app->plugin('ConsoleLogger') if $ENV{GALILEO_CONSOLE_LOGGER};
}

1;





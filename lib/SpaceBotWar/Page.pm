package SpaceBotWar::Page;
use Mojo::Base 'Mojolicious::Controller';

use SpaceBotWar::Client;
use SpaceBotWar::WS::Root;

my $ws_root = SpaceBotWar::WS::Root->new({
});

sub ws_home {
    my ($self) = @_;

    $ws_root->log($self->app->log);

    my $tx  = $self->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);
    my $client = SpaceBotWar::Client->new({
        tx      => $tx,
        name    => 'foo',
        id      => "$tx",
    });
    $ws_root->add_client($self, $client);
}

sub home {
    my $self = shift;

    $self->app->log->debug("GOT HOME!!!");

    $self->render;
}

sub foo {
    my $self = shift;

    $self->redirect_to("/");
}

sub show {
    my $self = shift;
    my $name = $self->param('name');

    my $page = $self->schema->resultset('Page')->single({ name => $name });
    if ($page) {
        $self->render( page => $page );
    } else {
        if ($self->session->{username}) {
            $self->redirect_to("/edit/$name");
        } else {
            $self->render_not_found;
        }
    }
}

sub edit {
    my $self = shift;
    my $name = $self->param('name');
    $self->title( "Editing Page: $name" );
    $self->content_for( banner => "Editing Page: $name" );

    my $schema = $self->schema;

    my $page = $schema->resultset('Page')->single({name => $name});
    if ($page) {
        my $title = $page->title;
        $self->stash( title_value => $title );
        $self->stash( input => $page->md );
    } else {
        $self->stash( title_value => '' );
        $self->stash( input => "Hello World" );
    }

    $self->stash( sanitize => $self->config->{sanitize} // 1 );     #/# highlight fix

    $self->render;
}

sub store {
    my $self = shift;
    $self->on( json => sub {
        my ($self, $data) = @_;

        my $schema = $self->schema;

        unless ( $data->{title} ) {
            $self->send({ json => {
                message => 'Not saved! A title is required!',
                success => \0,
            } });
            return;
        }

        my $author = $schema->resultset('User')->single({name=>$self->session->{username}});
        $data->{author_id} = $author->id;
        $schema->resultset('Page')->update_or_create(
            $data, {key => 'pages_name'},
        );
        $self->memorize->expire('main');
        $self->send({ json => {
            message => 'Changes saved',
            success => \1,
        } });
    });
}

1;


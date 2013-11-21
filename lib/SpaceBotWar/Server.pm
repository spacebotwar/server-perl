package SpaceBotWar::Server;
use Mojo::Base 'Mojolicious::Controller';

use SpaceBotWar::Client;
use SpaceBotWar::WS::Root;

# The game can only (currently) run one game at a time
# and all clients will connect to that (one) game.
#
my $ws_server;

# Initiate a new game by calling this URL
# (Obviously at some point we need to secure it)
# 
sub start_game {
    my ($self) = @_;

    $ws_server = SpaceBotWar::WS::Root->new({
        log     => $self->app->log,
    });
    $self->render( text => 'game started' );
}

# Allow a client to connect to the server
# 
sub ws_connect {
    my ($self) = @_;

    $ws_server->log($self->app->log);

    my $tx  = $self->tx;
    Mojo::IOLoop->stream($tx->connection)->timeout(0);
    my $client = SpaceBotWar::Client->new({
        tx      => $tx,
        name    => 'foo',
        id      => "$tx",
    });
    $ws_server->add_client($self, $client);
}

#
sub game {
    my ($self) = @_;

    $self->render( text => 'got here' );
}

1;


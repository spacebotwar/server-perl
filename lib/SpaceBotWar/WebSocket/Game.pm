package SpaceBotWar::WebSocket::Game;

use strict;
use warnings;

use parent qw(SpaceBotWar::WebSocket);

# This is the Game Lobby where people connect to to obtain the room
# (server) they need to connect to
#


sub render_json {
    my ($self, $room, $connection, $json) = @_;

    my $sent = JSON->new->encode($json);
    $connection->send($sent);
}


# A User attempting to 'register' a new username and password
#
sub ws_register {
    my ($self, $room, $connection) = @_;

    my $send = {
        route   => "/register_status",
        content => { 
            status  => 'ok',
            code    => 0,
            message => 'Welcome back!',
        },
    };
    $self->render_json($room, $connection, $send);
}

# A user has joined the room
#
sub on_connect {
    my ($self, $room, $connection) = @_;

    my $send = {
        route   => "/lobby_status",
        content => {
            status      => 'ok',
            code        => 0,
            message     => "Welcome to the game lobby",
        },
    };
    $self->render_json($room, $connection, $send);
}





1;

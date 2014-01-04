package SpaceBotWar::WebSocket::Player;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use Carp;
use UUID::Tiny ':std';
use JSON;

# Web client connections to the players
# TODO I'm not too happy having client and connection for each player.
# may want to refactor this at some point.

has client_a => (
    is          => 'rw',
);
has client_b => (
    is          => 'rw',
);
has connection_a => (
    is      => 'rw',
);
has connection_b => (
    is      => 'rw',
);


# this Web Socket server sends moves back to the client
# (the game server) based on the current position of the ships
#


# Initialise a player (get the code for the player)
# 
sub ws_init_players {
    my ($self, $context) = @_;

}

# Get the next move for the player
#
sub ws_next_move {
    my ($self, $context) = @_;

    # Flatten the arena into the match
    my $msg = {
        code        => 0,
        message     => "Success",
    };




    my $arena_hash = $self->arena->all_to_hash;
    @$msg{keys %$arena_hash} = values %$arena_hash;
    return $msg;

}

# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome',
        data        => 'player',
    };
}

1;

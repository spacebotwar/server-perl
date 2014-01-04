package SpaceBotWar::WebSocket::Player;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use Carp;
use UUID::Tiny ':std';
use JSON;
use Data::Dumper;

# this Web Socket server sends moves back to the client
# (the game server) based on the current position of the ships
#

has counter => (
    is          => 'rw',
    default     => 0,
);

sub BUILD {
    my ($self) = @_;

    # every half second, send a status message (for test purposes)
    #
    $self->log->debug("BUILD: PLAYER####### $self");
}

sub DESTROY {
    my ($self) = @_;

    $self->log->debug("DESTROY: PLAYER #### $self");
}




# Initialise a player (get the code for the player)
# 
sub ws_init_players {
    my ($self, $context) = @_;

}

# Get the next move for the player
#
sub ws_next_move {
    my ($self, $context) = @_;

    $self->counter($self->counter + 1);

    $self->log->debug("PLAYER RECV: ");
    return {
        code        => 0,
        message     => 'Next Move',
        data        => $self->counter,
    };
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

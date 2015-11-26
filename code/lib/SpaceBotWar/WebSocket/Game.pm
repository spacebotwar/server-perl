package SpaceBotWar::WebSocket::Game;

use Moose;

extends 'SpaceBotWar::WebSocket';

sub BUILD {
    my ($self) = @_;

    # every half second, send a status message (for test purposes)
    #
    $self->log->debug("BUILD: GAME####### $self");
}

1;

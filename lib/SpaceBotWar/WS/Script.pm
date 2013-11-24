package SpaceBotWar::WS::Script;

use Moose;
use Mojo::IOLoop;
use Data::Dumper;

use namespace::autoclean;

extends "SpaceBotWar::WS";

# This class is a web socket that performs the running of scripts.


# A message to indicate the current status of a game
#
sub msg_ship_update {
    my ($self, $client, $data) = @_;

    $self->log->debug("WS:Script. got here");

    # Read the current status of the tournament
    

    # Return the next step
    
}

__PACKAGE__->meta->make_immutable;

package SpaceBotWar::WebSocket::Test;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use Carp;
use UUID::Tiny ':std';
use JSON;
use Try;
use Data::Dumper;

# This is the common point into which everyone connects to. On this server
# it is possible to do the necessary commands to log in.
#

sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD START ###### $self");
}

sub DESTROY {
    my ($self) = @_;

    $self->log->debug("DESTROY: START #### $self");
}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH: START #### $self");
}

# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to Space Bot War!',
    };
}

1;

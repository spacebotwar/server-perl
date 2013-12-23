package SpaceBotWar::WebSocket::Start;

use Moose;
use MooseX::NonMoose;

extends 'SpaceBotWar::WebSocket';

sub BUILD {
    my ($self) = @_;

    print STDERR "BUILD: SpaceBotWar::WebSocket::Start $self\n";
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket::Start $self\n";
}

1;

package SpaceBotWar::WebSocket::Start;

use Moose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
);

sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD");
}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH");
}

1;

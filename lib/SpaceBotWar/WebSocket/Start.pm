package SpaceBotWar::WebSocket::Start;

use Moose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
);

has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
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

package SpaceBotWar::WebSocket::Match;

use Moose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
);

has log => (
    is        => 'rw',
    default => sub {
        return Log::Log4perl->get_logger("SpaceBotWar::WebSocket");
    },
);

sub BUILD {
    my ($self) = @_;
    
    $self->log->debug("BUILD");
    my $ws = AnyEvent->timer(
        after       => 0.0,
        interval    => 0.5,
        cb          => sub {
            $self->log->debug("TIMER");
        },
    );
    $self->timer($ws);
}



1;

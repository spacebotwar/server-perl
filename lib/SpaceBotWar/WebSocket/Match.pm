package SpaceBotWar::WebSocket::Match;

use Moose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
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

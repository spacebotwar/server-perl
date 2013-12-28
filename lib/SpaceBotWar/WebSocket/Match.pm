package SpaceBotWar::WebSocket::Match;

use Moose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
);

sub BUILD {
    my ($self) = @_;

    print STDERR "BUILD: SpaceBotWar::WebSocket::Match $self\n";
    my $ws = AnyEvent->timer(
        after       => 0.0,
        interval    => 0.5,
        cb          => sub {
            print STDERR "TIMER: $self\n";
        },
    );
    $self->timer($ws);
}



1;

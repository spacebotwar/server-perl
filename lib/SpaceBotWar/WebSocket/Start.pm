package SpaceBotWar::WebSocket::Start;

use Moose;
use MooseX::NonMoose;

extends 'SpaceBotWar::WebSocket';

has 'timer' => (
    is      => 'rw',
);

sub BUILD {
    my ($self) = @_;

    print STDERR "BUILD: SpaceBotWar::WebSocket::Start $self\n";
#    my $ws = AnyEvent->timer(
#        after       => 0.0,
#        interval    => 0.5,
#        cb          => sub {
#            print STDERR "TIMER: $self\n";
#        },
#    );
#    $self->timer($ws);
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket::Start $self\n";
}

1;

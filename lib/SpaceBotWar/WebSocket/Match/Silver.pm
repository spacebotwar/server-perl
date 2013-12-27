package SpaceBotWar::WebSocket::Match::Silver;

use Moose;

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;

sub BUILD {
    my ($self) = @_;

    print STDERR "BUILD: SpaceBotWar::WebSocket::Match::Silver $self\n";
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket::Match::Silver $self\n";
}

# A user has joined the room
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to the arena',
        data        => 'silver arena',
    };
}

1;

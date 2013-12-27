package SpaceBotWar::WebSocket::Match::Gold;

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

    print STDERR "BUILD: SpaceBotWar::WebSocket::Match::Gold $self\n";
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket::Match::Gold $self\n";
}
sub ws_test {
    my ($self, $context) = @_;

    return {
        code    => 0,
        message => "Success",
        profile => {
            username    => 'test_user_1',
            email       => 'me@example.com',
        },
    };
}


# A user has joined the room
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to the arena',
        data        => 'gold arena',
    };
}

1;

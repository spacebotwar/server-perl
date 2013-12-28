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

# Get the arena status
#

sub ws_arena_status {
    my ($self, $context) = @_;

    return {
        code    => 0,
        message => "Success",
        spectators  => 23,
        start_time  => -35.5,
        status      => "running",
        competitors => [{
            name        => "Scaredy Pants",
            rank        => 37,
            programmer  => "Dr Death",
            health      => "34",
        },{
            name        => "Hunter",
            rank        => 42,
            programmer  => "Blotto",
            health      => "12",
        }],
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

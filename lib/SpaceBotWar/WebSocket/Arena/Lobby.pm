package SpaceBotWar::WebSocket::Arena::Lobby;

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

    print STDERR "BUILD: SpaceBotWar::WebSocket::Arena::Lobby $self\n";
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket::Arena::Lobby $self\n";
}

# Return a list of valid arean rooms
#
sub ws_arenas {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => "Arenas",
        arenas      => [{
            route       => "/ws/match/gold",
            spectators  => 2,
            start_time  => -3,
            status      => "running",
            competitors => [{
                name        => "Scaredy Pants",
                rank        => 37,
                programmer  => "Dr Death",
            },{
                name        => "Hunter",
                rank        => 32,
                programmer  => "Blotto",
            }],
        },{
            route       => "/ws/match/silver",
            spectators  => 44,
            start_time  => -30.5,
            status      => "running",
            competitors => [{
                name        => "Total Chaos",
                rank        => 56,
                programmer  => "Saving Memo",
            },{
                name        => "Chase own tail",
                rank        => 76,
                programmer  => "K-OS",
            }],
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
        data        => 'arena',
    };
}

1;

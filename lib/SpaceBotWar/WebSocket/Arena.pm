package SpaceBotWar::WebSocket::Arena;

use Moose;

extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;

sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD");
}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH");
}

# Return a list of valid arena servers
#
sub ws_arenas {
    my ($self, $context) = @_;

    my $config = SpaceBotWar->config;

    my $server = $config->get("ws_servers/server");

    return {
        code        => 0,
        message     => "Arenas",
        arenas      => [{
            server       => "$server/ws/match/rae",
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
            server      => "$server/ws/match/scott",
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




# A user has joined the server
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

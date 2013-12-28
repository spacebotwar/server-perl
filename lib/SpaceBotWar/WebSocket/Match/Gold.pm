package SpaceBotWar::WebSocket::Match::Gold;

use Moose;

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;

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

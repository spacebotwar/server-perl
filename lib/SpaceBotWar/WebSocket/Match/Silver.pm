package SpaceBotWar::WebSocket::Match::Silver;

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

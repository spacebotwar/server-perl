package SpaceBotWar::WebSocket::ClientPlayer;

use Moose;

# Code that manages a client connection to a Player WebSocket.
#
has id => (
    is      => 'rw',
    isa     => 'Int',
);

has client => (
    is      => 'rw',
    isa     => 'AnyEvent::WebSocket::Client',
);

has connection => (
    is      => 'rw',
    isa     => 'AnyEvent::WebSocket::Connection',
);

has state => (
    is      => 'rw',
    isa     => 'Str',
    default => 'init',
);

has arena => (
    is      => 'rw',
    isa     => 'SpaceBotWar::Game::Arena',
);

# Process the '/game_state' Web Socket call
#
sub ws_game_state {
    my ($self, $msg) = @_;

    # some basic validation. need to improve
    if (defined $msg->{content} and defined $msg->{content}{code} and $msg->{content}{code} == 0) {
        my $data = $msg->{content}{data};
        if ($data) {
            eval {
                $self->arena->accept_move($self->id, $data);
            };
            if ($@) {
                $self->log->error($@);
            }
        }
        else {
            $self->log->info("###### no {content}{data} #######");
        }
    }
}





1;

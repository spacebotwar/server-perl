package SpaceBotWar::WebSocket::Match;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use Carp;
use UUID::Tiny ':std';
use JSON;

has timer => (
    is      => 'rw',
);

has arena => (
    is      => 'rw',
    default => sub {
        return SpaceBotWar::Game::Arena->new({});
    },
);

sub BUILD {
    my ($self) = @_;
    
    $self->log->info("BUILD $self");
    my $ws = AnyEvent->timer(
        after       => 0.0,
        # should be every 0.5 seconds, but slow it down during debugging!
        interval    => 5.0,
        cb          => sub {
            $self->tick;
        },
    );
    $self->timer($ws);

}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH");
}


# Tick the arena, broadcast the current state
# to all the clients
#
sub tick {
    my ($self) = @_;

    $self->arena->tick(5);

    my $msg = {
        code        => 0,
        message     => 'Match Status',
        spectators  => $self->number_of_clients,
    };
    # Flatten the arena into the match hash
    my $arena_hash = $self->arena->dynamic_to_hash;
    @$msg{keys %$arena_hash} = values %$arena_hash;
    $self->broadcast_json("/match_tick", $msg);
}


# Get the match status
#
sub ws_match_status {
    my ($self, $context) = @_;

    # Flatten the arena into the match
    my $msg = {
        code        => 0,
        message     => "Success",
        spectators  => $self->number_of_clients,
    };
    my $arena_hash = $self->arena->all_to_hash;
    @$msg{keys %$arena_hash} = values %$arena_hash;
    return $msg;

}


# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to the match',
        data        => 'match',
    };
}

1;

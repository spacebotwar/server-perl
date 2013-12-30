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

has status => (
    is      => 'rw',
    default => 'ready',
);

has game_time => (
    is      => 'rw',
    default => -10,
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
            $self->_tick;
        },
    );
    $self->timer($ws);

}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH");
}

sub _tick {
    my ($self) = @_;

    my $msg = {};

    if ($self->status eq 'ready') {
        # set up a new match
        #
        $self->game_time(-10);
        $self->status('waiting');
    }
    elsif ($self->status eq 'waiting') {
        # Waiting for the match to start.
        
        # When the match starts
        if ($self->game_time > 0) {
            $self->status('running');
        }
    }
    elsif ($self->status eq 'running') {
        # The match is in progress
        $self->tick;

        # When the match is over...
        if ($self->game_time > 100) {
            $self->game_time(-5);
            $self->status('completed');
        }
    }
    elsif ($self->status eq 'completed') {
        # The match is over.

        # Reset back to 'ready'
        if ($self->game_time > 0) {
            $self->game_time(-10);
            $self->status('ready');
        }
    }
    $self->game_time($self->game_time + 0.5);

    $msg = {
        game_time   => $self->game_time,
        status      => $self->status,
    };
    $self->broadcast_json($msg);
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
        arena       => $self->arena->dynamic_to_hash,
    };
    $self->broadcast_json($msg);
}


# Get the match status
#
sub ws_match_status {
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

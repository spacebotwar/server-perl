package SpaceBotWar::WebSocket::Match;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use Carp;
use UUID::Tiny ':std';
use JSON;
use AnyEvent::WebSocket::Client;

has timer => (
    is      => 'rw',
);

has arena => (
    is      => 'rw',
    default => sub {
        return SpaceBotWar::Game::Arena->new({});
    },
);

# I'm not happy with these four, look at refactoring.
# TODO must refactor this code.
#
has player_clients => (
    is      => 'rw',
    default => sub { [] },
);

has player_connections => (
    is      => 'rw',
    default => sub { [] },
);



sub BUILD {
    my ($self) = @_;
    
    $self->log->info("BUILD MATCH#######");
    my $ws = AnyEvent->timer(
        after       => 0.0,
        # should be every 0.5 seconds, but slow it down during debugging!
        interval    => 5.0,
        cb          => sub {
            $self->tick;
        },
    );
    $self->timer($ws);

    # TODO Just whilst testing
    $self->ws_start_match;

}

sub DEMOLISH {
    my ($self) = @_;

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

    # transmit the status to each player
    foreach my $id (0..1) {
        if ($self->player_connections->[$id]) {
            $self->log->debug("########## Sending player status [$self][$id]");
            $msg->{player} = $id;
            $self->send_json($self->player_connections->[$id], '/next_move', $msg);
        }
    }

    # broadcast to all watchers
    $self->broadcast_json("/match_tick", $msg);
}


# Start a new match
# TODO: Look at making this work from a beanstalk job queue
# 
sub ws_start_match {
    my ($self, $context) = @_;

    foreach my $id (0..1) {
        # Close existing connections
        if ($self->player_connections->[$id]) {
            $self->player_connections->[$id]->close;
        }
        # at some point the server will be configurable
        my $server = SpaceBotWar->config->get('ws_servers/player');
        $self->player_clients->[$id] = AnyEvent::WebSocket::Client->new;
        $self->log->info("Connect to player $server");
        $self->player_clients->[$id]->connect($server)->cb(sub {

            $self->player_connections->[$id] = eval { shift->recv };
            if ($@) {
                $self->log->error("Cannot connect to server [$server] id [$id]");
            }
            else {
                $self->player_connections->[$id]->on(finish => sub {
                    $self->log->info("Connection finished. [$server] id [$id]");
                });

                $self->player_connections->[$id]->on(each_message => sub {
                    my ($connection, $message) = @_;
                    my $json = JSON->new->decode($message->body);

                    $self->log->debug("Received player message... [".$message->body."]");
                });
            }
        });
    }
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

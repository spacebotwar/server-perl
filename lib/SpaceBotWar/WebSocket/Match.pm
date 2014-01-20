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

# 'player_clients' are the two players who are providing ship movement
# instructions based on their program.
#
has player_clients => (
    is      => 'rw',
    default => sub { [] },
);

# 'player_connections' are the connection objects for each of the two
# 'player_clients'
#
has player_connections => (
    is      => 'rw',
    default => sub { [] },
);
# Note that there are also 'clients' who are managed by the parent WebSocket
# class and who are the people connecting to watch the match in real-time
#



# When we create this object, we need to set up a tick timer.
# which keeps track of the game progression
#
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

# Tick the arena, broadcast the current state
# to each Player and to all the watchers.
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
    my $arena_hash = $self->arena->to_hash;

    @$msg{keys %$arena_hash} = values %$arena_hash;

    # transmit the status to each player
    foreach my $id (0..1) {
        if ($self->player_connections->[$id]) {
            $msg->{player} = $id + 1;
            $self->log->debug("@@@@@@@@@@@@@@@@@@@@@ status=[".$self->arena->status."] @@@@@@@@@@@@@@@@@@@");
            if ($self->arena->status eq 'starting') {
                $self->send_json($self->player_connections->[$id], '/start_state', $msg);
            }
            else {
                $self->send_json($self->player_connections->[$id], '/game_state', $msg);
            }
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

    $self->arena->status('init');
    $self->log->info("@@@@@@@@ START MATCH @@@@@@@@");

    my @player_clients;
    my @player_connections;

    foreach my $id (0..1) {
        # at some point the server will be configurable
        my $server = SpaceBotWar->config->get('ws_servers/player');
        $player_clients[$id] = AnyEvent::WebSocket::Client->new;
        $self->log->info("Connect to player $server");
        $player_clients[$id]->connect($server)->cb(sub {

            $player_connections[$id] = eval { shift->recv };
            if ($@) {
                $self->log->error("Cannot connect to server [$server] id [$id]");
            }
            else {
                $player_connections[$id]->on(finish => sub {
                    $self->log->info("@@ CONNECTION FINISHED @@. [$server] id [$id]");
                });

                $player_connections[$id]->on(each_message => sub {
                    my ($connection, $message) = @_;
                    my $json = JSON->new->decode($message->body);

                    $self->log->info("<<<< RECEIVED PLAYER MESSAGE >>>>... [".$message->body."]");
                    my $msg = JSON->new->decode($message->body);

                    # Game State received
                    if ($msg->{route} eq '/game_state' and defined $msg->{code} and $msg->{code} == 0 ) {
                       # TODO: We need to do some validation on the received data at some point...
                       #
                       my $data = $msg->{content}{data};
                       if ($data) {
                           eval {
                               $self->arena->accept_move($id+1, $data);
                           };
                           if ($@) {
                               $self->log->error($@);
                           }
                       }
                    }
                });
            }
        });
    }
    $self->player_connections(\@player_connections);
    $self->player_clients(\@player_clients);

    $self->log->info("@@ end of ws_start_match @@");
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

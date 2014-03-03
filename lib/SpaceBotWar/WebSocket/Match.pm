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
use SpaceBotWar::WebSocket::ClientPlayer;

# This is the Web Socket responsible for running a match. Currently the
# code is written so that it only runs one match at a time, this may change
# in the future.
#
# the code also makes two Web Socket connections to Web Socket Servers
# that are responsible for running the players code.
# This gives us a degree of isolation from the potentially dangerous client
# code and also gives us the option in the future to allow players to run
# their code on their own servers.
#

# The 'timer' is responsible for keeping track of the game time by 
# 'ticking' at a regular interval
#
has timer => (
    is      => 'rw',
);

# The 'arena' is the definition of the game area
#
has arena => (
    is      => 'rw',
    default => sub {
        return SpaceBotWar::Game::Arena->new({});
    },
);

# 'client_players' are the client connections to WebSocket::Player which are
# the servers responsible for running the players code and returning
# the results
#
has client_players => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::WebSocket::ClientPlayer]',
);

# When we create this object, we need to set up a tick timer.
# which keeps track of the game progression
#
sub BUILD {
    my ($self) = @_;
    
    $self->log->info("BUILD MATCH#######");
    my $ws = AnyEvent->timer(
        after       => 0.0,
        interval    => 0.5,
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

    if ($self->arena->start_time > 300) {
        $self->ws_start_match;
        return;
    }

    my $msg = {
        code        => 0,
        message     => 'Match Status',
        spectators  => $self->number_of_clients,
    };
    my $arena_hash = $self->arena->to_hash;

    # Flatten the arena into the match hash
    @$msg{keys %$arena_hash} = values %$arena_hash;


    # transmit the status to each player
    foreach my $id (0..1) {
        my $client_player = $self->client_players->[$id];

        $msg->{player}  = $id + 1;
        my $route       = ($self->arena->status eq 'starting') ? '/start_state' : '/game_state';

        if ($client_player->connection) {
            # this is a little messy!
            $self->log->debug("state [".$client_player->state."] ");
            if ($client_player->state eq 'connected') {
                $self->log->debug("######### connected #########");
                my $msg = {
                    server_secret   => SpaceBotWar->config->get('server_secrets/player'),
                    program_id      => 1,
                };
                $self->send_json($client_player->connection, '/init_program', $msg);
                $client_player->state('running');
            }
            $self->send_json($client_player->connection, $route, $msg);
        }
    }
    delete $msg->{player};
    
    # broadcast to all watchers
    $self->broadcast_json("/match_tick", $msg);
}


# Start a new match
# TODO: Look at making this work from a beanstalk job queue
# 
sub ws_start_match {
    my ($self, $context) = @_;

    $self->arena->status('init');
    $self->log->info("START MATCH");

    my @client_players = ();
    $self->client_players(\@client_players);
    
    foreach my $id (0..1) {
        my $client_player = SpaceBotWar::WebSocket::ClientPlayer->new({
            id          => $id + 1,
            client      => AnyEvent::WebSocket::Client->new,
            state       => 'init',
            arena       => $self->arena,
        });
        $client_players[$id] = $client_player;

        # at some point the server will be configurable
        my $server = SpaceBotWar->config->get('ws_servers/player');
        $self->log->debug("Connect to player $server");
        $client_player->client->connect($server)->cb(sub {
            my $connection = eval { shift->recv };
            if ($@) {
                $self->log->error("Cannot connect to server [$server] id [$id]");
                $client_player->state('fail');
            }
            else {
                $client_player->connection($connection);
                
                $self->log->debug("Connected to server [$server] id [$id]");
                $client_player->state('connected');

                $client_player->connection->on(each_message => sub {
                    my ($connection, $message) = @_;
                    my $msg = JSON->new->decode($message->body);

                    my $route = $msg->{route};
                    $route =~ s{^/}{};
                    $route = "ws_".$route;
                    if ($client_player->can($route)) {
                        $client_player->$route($msg);
                    }
                    else {
                        # TODO Flag an error (how?)
                    }
                });
            }
        });
    }
    $self->log->info("End of ws_start_match");
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

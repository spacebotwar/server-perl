package SpaceBotWar::WebSocket::Player;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use SpaceBotWar::Game::Ship::Mine;
use SpaceBotWar::Game::Ship::Enemy;
use Carp;
use UUID::Tiny ':std';
use JSON;
use Data::Dumper;
use Math::Round qw(nearest round);

has scratchpads => (
    is          => 'rw',
    isa         => 'HashRef',
    default     => sub { {} },
);

# this Web Socket server sends moves back to the client
# (the game server) based on the current position of the ships
#
# The module can handle multiple connections, each one of which
# is a separate connection, so each one needs it's own data.
# which we can instantiate during the 'on_establish' method call
#
after 'on_establish' => sub {
    my ($self, $connection, $env) = @_;

    $self->log->debug("AFTER ON_ESTABLISH");
    $self->scratchpads->{$connection} = {};
};

# And kill before we do a final kill of the connection
# 
before 'kill_client_data' => sub {
    my ($self, $connection) = @_;

    delete $self->scratchpads->{$connection};
    $self->log->info("killed scratchpad data");
};


# Helper method for scratchpad
#
sub scratchpad {
    my ($self,$connection) = @_;

    return $self->scratchpads->{$connection};
}


sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD: PLAYER####### $self");
}


sub DESTROY {
    my ($self) = @_;

    $self->log->debug("DESTROY: PLAYER #### $self");
}


# Initialise a program (get the code for the program)
# 
sub ws_init_program {
    my ($self, $context) = @_;

    my $program_id = $context->param('program_id');


    # Read the program into a string.

    

    # We would get this from the file system, or GIT

    return {
        code        => 0,
        message     => 'Program',
        program     => {
            id          => 456,
            name        => "Thunderball",
            author      => 'icydee',
            author_id   => 123,
            created     => '2013-01-01 00:00:00',
            cloned_from => 'foo',
        }
    };
}



# Receive the initial state of the game
#
sub ws_start_state {
    my ($self, $context) = @_;

    my $scratchpad = $self->scratchpad($context->connection);

    $scratchpad->{competitors}  = $context->param('competitors');
    $scratchpad->{ships_static} = $context->param('ships');
}



my $test_code = <<'END';
    foreach my $ship (@my_ships) {
        $ship->thrust_forward(round(rand(60)));
        $ship->thrust_sideway(round(rand(10)));
        $ship->thrust_reverse(round(rand(20)));
        $ship->rotation(nearest(0.01, rand(2) - 1));
    }
END









# Update with the latest game state of the match
#
sub ws_game_state {
    my ($self, $context) = @_;

    my $con_data = $self->connections->{$context->connection};

    my $player_id = $context->param('player');

    my @my_ships;
    my @enemy_ships;
    foreach my $ship_hash (@{$context->param('ships')}) {
        my $ship;
        if ($ship_hash->{owner_id} == $player_id) {
            $ship = SpaceBotWar::Game::Ship::Mine->new({
                id              => $ship_hash->{id},
                owner_id        => $ship_hash->{owner_id},
#                status          => $ship_hash->{status},
#                health          => $ship_hash->{health},
#                x               => $ship_hash->{x},
#                y               => $ship_hash->{y},
#                rotation        => $ship_hash->{rotation},
#                orientation     => $ship_hash->{orientation},
#                thrust_forward  => $ship_hash->{thrust_forward},
#                thrust_sideway  => $ship_hash->{thrust_sideway},
#                thrust_reverse  => $ship_hash->{thrust_reverse},
            });
            push @my_ships, $ship;
        }
        else {
            $ship = SpaceBotWar::Game::Ship::Enemy->new({
                id              => $ship_hash->{id},
                owner_id        => $ship_hash->{owner_id},
#                status          => $ship_hash->{status},
#                health          => $ship_hash->{health},
#                x               => $ship_hash->{x},
#                y               => $ship_hash->{y},
#                rotation        => $ship_hash->{rotation},
#                orientation     => $ship_hash->{orientation},
            });
            push @enemy_ships, $ship;
        }
    }

    my @ship_moves;
    foreach my $ship (@my_ships) {
        my $move = {
            ship_id         => $ship->{id},
            thrust_forward  => round(rand(60)),
            thrust_sideway  => round(int(rand(10))),
            thrust_reverse  => round(int(rand(20))),
            rotation        => nearest(0.01, rand(2) - 1),
        };
        push @ship_moves, $move;
    }

    $self->log->info(Dumper(\@my_ships));
    return {
        code        => 0,
        message     => 'Game State',
        data        => {
            ships   => \@ship_moves,
        },
    };
}

# A user (a match server) has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => "Welcome to ".$self->server,
        data        => 'player',
    };
}

1;

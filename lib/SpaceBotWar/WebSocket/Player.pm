package SpaceBotWar::WebSocket::Player;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use SpaceBotWar::Game::Data;
use SpaceBotWar::Game::Ship::Mine;
use SpaceBotWar::Game::Ship::Enemy;
use Carp;
use UUID::Tiny ':std';
use JSON;
use Data::Dumper;
use Math::Round qw(nearest round);
use Safe;
use Safe::Hole;

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
    $self->log->warn("DESTROY: PLAYER #### $self");
}


# Initialise a program (get the code for the program)
# 
sub ws_init_program {
    my ($self, $context) = @_;

    my $program_id = $context->param('program_id');


    # Read the program into a string.
    my $scratchpad = $self->scratchpad($context->connection);
    # TODO For now hard code it, shortly get it from the file store.
    #
    $scratchpad->{code} = <<'END';
        foreach my $ship (@{$data->my_ships}) {
            $ship->thrust_forward(rand(60));
            $ship->thrust_sideway(rand(10));
            $ship->thrust_reverse(rand(20));
            $ship->rotation(rand(2) - 1);
        }
        return 1;
END

    # We would get this from the file system, or GIT
    $self->log->debug("[[[[[[[[[[[[[[[[[[[ ".$scratchpad->{code}." ]]]]]]]]]]]]]]]]]]]");
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






# Merge the game state into the scratchpad for a specific ship
#
sub merge_scratchpad {
    my ($self, $scratchpad, $ship_hash) = @_;

    my ($sp_hash) = grep {$_->{id} == $ship_hash->{id}} @{$scratchpad->{ships_static}};
    if ($sp_hash) {
        $sp_hash->{x}           = $ship_hash->{x};
        $sp_hash->{y}           = $ship_hash->{y};
        $sp_hash->{rotation}    = $ship_hash->{rotation};
        $sp_hash->{orientation} = $ship_hash->{orientation};
        $sp_hash->{status}      = $ship_hash->{status};
        $sp_hash->{direction}   = $ship_hash->{direction};
        $sp_hash->{health}      = $ship_hash->{health};
    }
    else {
        die "could not find hash for ship";
    }
    return $sp_hash;
}



# Update with the latest game state of the match
#
sub ws_game_state {
    my ($self, $context) = @_;

    my $scratchpad = $self->scratchpad($context->connection);
  
    my $player_id = $context->param('player');

    # Create the objects to be used in the ship movement calculations
    #
    my @my_ships;
    my @enemy_ships;
    foreach my $ship_hash (@{$context->param('ships')}) {
        # Add the data to the scratchpad.
        my $sp_hash = $self->merge_scratchpad($scratchpad, $ship_hash);

        my $ship;
        if ($sp_hash->{owner_id} == $player_id) {
            $ship = SpaceBotWar::Game::Ship::Mine->new({
                id              => $sp_hash->{id},
                owner_id        => $sp_hash->{owner_id},
                status          => $sp_hash->{status},
                health          => $sp_hash->{health},
                x               => $sp_hash->{x},
                y               => $sp_hash->{y},
                rotation        => $sp_hash->{rotation},
                orientation     => $sp_hash->{orientation},
                thrust_forward  => $sp_hash->{thrust_forward},
                thrust_sideway  => $sp_hash->{thrust_sideway},
                thrust_reverse  => $sp_hash->{thrust_reverse},
            });
            push @my_ships, $ship;


            # TODO This is just for test purposes. remove in Production!
            # In practices, this will be determined by the Program Code running for this player
            #
        }
        else {
            $ship = SpaceBotWar::Game::Ship::Enemy->new({
                id              => $ship_hash->{id},
                owner_id        => $ship_hash->{owner_id},
                status          => $ship_hash->{status},
                health          => $ship_hash->{health},
                x               => $ship_hash->{x},
                y               => $ship_hash->{y},
                rotation        => $ship_hash->{rotation},
                orientation     => $ship_hash->{orientation},
            });
            push @enemy_ships, $ship;
        }
    }

    my $data = SpaceBotWar::Game::Data->new({
        my_ships        => \@my_ships,
    });

    # This is where we call the code to calculate the ship movements
    # 
    my $compartment = new Safe;
    my $hole = Safe::Hole->new({});
    $hole->wrap($data, $compartment, '$data');
    $compartment->permit('rand','srand');

    my @ship_moves;

    my $test_code = $scratchpad->{code};
    $self->log->debug("Code is $test_code");
    my $result = $compartment->reval($test_code);
    if ($@) {
        $self->log->error("=========== could not evaluate code =========== $@");
        die "Could not evaluate code ==================================== $@";
    }
    $self->log->debug("...................... [$result]..................");

    # Report the moves for this tick for my own ships
    #
    foreach my $ship (@{$data->my_ships}) {
        my $move = {
            ship_id         => $ship->id,
            thrust_forward  => $ship->thrust_forward,
            thrust_sideway  => $ship->thrust_sideway,
            thrust_reverse  => $ship->thrust_reverse,
            rotation        => $ship->rotation,
        };
        push @ship_moves, $move;
    }

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

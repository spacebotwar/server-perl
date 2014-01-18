package SpaceBotWar::Game::Arena;

# An arena contaning many ships

use Moose;
use namespace::autoclean;
use Data::Dumper;
use Log::Log4perl;

use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;

# An array of all the ships in the Arena
#
has 'ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ship]',
    default => sub { [] },
);


# This size (radius) of the arena (in pixels)
has radius  => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);

# The 'time' (in seconds) from when the Tournament was started
# 
has 'start_time' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# Competitors
#
has 'competitors' => (
    is      => 'rw',
);

# Arena Status
#
has 'status' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'starting',
);

# log4perl logger
has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
);

# An arena is assumed to be a circle of radius $self->radius
# with the x,y origin in the centre.


# Create an Arena with standard ships
#
sub BUILD {
    my ($self) = @_;

    $self->_initialize;
}

# Set initial ship positions.
sub _initialize {
    my ($self) = @_;
    
    my $ship_layout = {
        1   => { x => -350, y => -350, direction => PI/4 },
        2   => { x => -400, y => -350, direction => PI/4 },
        3   => { x => -350, y => -400, direction => PI/4 },
        4   => { x => 350, y => 350, direction => PI/4 + PI },
        5   => { x => 400, y => 350, direction => PI/4 + PI },
        6   => { x => 350, y => 400, direction => PI/4 + PI },
    };
    my @ships;
    foreach my $ship_id (sort keys %$ship_layout) {
        my $ship_ref = $ship_layout->{$ship_id};
    $self->log->debug(Dumper($ship_ref));

        my $ship = SpaceBotWar::Game::Ship->new({
            id              => $ship_id,
            owner_id        => int(($ship_id - 1) / 3) + 1,
            type            => 'ship',
            x               => $ship_ref->{x},
            y               => $ship_ref->{y},
            thrust_forward  => 0,
            thrust_sideway  => 0,
            thrust_reverse  => 0,
            orientation     => $ship_ref->{direction} || 0,
            rotation        => 0,
        });
        push @ships, $ship;
    }
    $self->ships(\@ships);
    $self->start_time(-5);
    $self->status('starting');
}

before 'status' => sub {
    my ($self, $val) = @_;

    if (defined $val) {
        if ($val eq 'init') {
            $self->_initialize;            
        }
    }
};

# Accept a players move
#   thrust_forward
#   thrust_sideway
#   thrust_reverse
#   rotation
sub accept_move {
    my ($self, $owner_id, $data) = @_;

#    $self->log->info("ACCEPT MOVE: ".Dumper($data));
    if ($data->{ships}) {
        foreach my $ship_data (@{$data->{ships}}) {

#$self->log->info("SET SHIP SPEED: ".Dumper($ship_data));

        my ($ship) = grep {$_->id == $ship_data->{ship_id}} @{$self->{ships}};
        confess [1000, "Cannot find ship with id [".$ship_data->{id}."]" ] if not defined $ship;
        confess [1000, "Can only control your own ships! [".$ship_data->{id}."]" ] if $ship->owner_id != $owner_id;
        $ship->thrust_forward($ship_data->{thrust_forward});
        $ship->thrust_reverse($ship_data->{thrust_reverse});
        $ship->thrust_sideway($ship_data->{thrust_sideway});
        $ship->rotation($ship_data->{rotation});
        }
    }
}


# Update the arena by $duration (10ths of a second)
#   most likely 'duration' will be 5 (half a second)
#
sub tick {
    my ($self, $duration) = @_;

    my $duration_millisec = $duration * 100;
    $self->start_time($self->start_time + $duration / 10);

    if ($self->status eq 'starting' and $self->start_time >= 0) {
        $self->status('running');
    }
    if ($self->status ne 'running') {
#        return;
    }



    # In practice, on each tick, we give the current actual position of all
    # ships and the thrust and rotation (as we currently know it)
    #
    # Up until the next tick, each ship's new thrust and rotation will be received
    # from each player and this will be used to compute the actual position for
    # the next tick.
    #
    # The competing programs will only know the predicted thrust and rotation for
    # the opposing fleet, not what will happen during the tick (e.g. full forward to
    # full reverse) so the predictions will often be 'wrong'.
    #
    # For this reason we can't use the predicted value to display the game in the
    # browser, we have to use the actual values. This means the browser display
    # has to lag by 1 tick behind the actual game play.
    #
    # We will have to look at what this means when players are playing 'manually'.
    # 
    #
    # So, as mentioned above. This code currently assumes that the thrust and rotation
    # were received during the previous tick period, only to be acted upon now 'as if'
    # the command were received at the start of the previous tick period.
    # 

    my $radius_squared = $self->radius * $self->radius;

    foreach my $ship (@{$self->ships}) {
        # No longer check for limits here, all done in the Ship module!
        $self->log->info("SHIP CALC: ".$ship." thrust_forward=[".$ship->thrust_forward."] speed=[".$ship->speed."]");            
        # Calculate the final position based on thrust and direction
        my $distance = $ship->speed * $duration_millisec / 1000;
        my $delta_x = $distance * cos($ship->direction);
        my $delta_y = $distance * sin($ship->direction);
        my $end_x = int($ship->_x + $delta_x);
        my $end_y = int($ship->_y + $delta_y);
    
        # check for limits.
        if ($end_x * $end_x + $end_y * $end_y > $radius_squared) {
            # Then outside the bounds of the arena, bring it back.
            my $angle = atan2($end_y, $end_x);
            $end_x = cos($angle) * 1000;
            $end_y = sin($angle) * 1000;
        }
    
        # Check for collisions, in which case come to an early halt
    
        # Check for hits by missiles. In which case cause damage
    
        $ship->_x($end_x);
        $ship->_y($end_y);
   
        # angle of rotation over the tick.
        my $angle_rad = $ship->rotation * $duration_millisec / 1000;
        $ship->orientation($ship->orientation+$angle_rad);
    }
}

# Create a hash representation of the changing data in the object
# Omit static information that can be read once, and cached, in
# order to reduce the size of the frequent data.
#
sub dynamic_to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->dynamic_to_hash;
    }
    return {
        status  => $self->status,
        time    => $self->start_time,
        ships   => \@ships_ref,
    };
}

# Everything about the arena, cache the static bits
# Ideally send this once to each client at the start.
#
sub all_to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->all_to_hash;
    }
    return {
        status  => $self->status,
        width   => $self->width,
        height  => $self->height,
        time    => $self->start_time,
        ships   => \@ships_ref,
    };
}

__PACKAGE__->meta->make_immutable;



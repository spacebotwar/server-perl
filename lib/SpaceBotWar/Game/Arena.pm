package SpaceBotWar::Game::Arena;

# An arena contaning many ships

use Moose;
use namespace::autoclean;
use Data::Dumper;

use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;

# An array of all the ships in the Arena
#
has 'ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ship]',
    default => sub { [] },
);


# NOTE: I prefer a circular arena, but we will stick with
# rectangular for now!


# The width of the arena (in pixels)
#
has 'width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);
# The height of the arena (in pixels)
#
has 'height' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);
# The 'time' (in seconds) from when the Tournament was started
# 
has 'start_time' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# The duration (in milliseconds) from each calculation
#
has 'duration' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
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

# log4pel logger
has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
);

# Create an Arena with standard ships
#
sub BUILD {
    my ($self) = @_;

    $self->_initiate;
}

# Set initial ship positions.
sub _initiate {
    my ($self) = @_;
    
    my $ship_layout = {
       
        1   => { x => 150, y => 150, direction => PI/4 },
        2   => { x => 100, y => 150, direction => PI/4 },
        3   => { x => 150, y => 100, direction => PI/4 },
        4   => { x => 350, y => 350, direction => PI/4 + PI },
        5   => { x => 400, y => 350, direction => PI/4 + PI },
        6   => { x => 350, y => 400, direction => PI/4 + PI },
    };

    my @ships;
    foreach my $ship_id (sort keys %$ship_layout) {
        my $ship_ref = $ship_layout->{$ship_id};

        my $ship = SpaceBotWar::Game::Ship->new({
            id              => $ship_id,
            owner_id        => int(($ship_id - 1) / 3) + 1,
            type            => 'ship',
            x               => $ship_ref->{x},
            y               => $ship_ref->{y},
            thrust_forward  => 0,
            thrust_sideway  => 0,
            thrust_reverse  => 0,
            orientation     => $ship_ref->{direction},
            rotation        => 0,
        });
        push @ships, $ship;
    }
    $self->ships(\@ships);
    $self->start_time(0);
}

before 'status' => sub {
    my ($self, $val) = @_;

    if (defined $val) {
        if ($val eq 'init') {
            $self->_initiate;            
        }
    }
};

# Accept a players move
#
sub accept_move {
    my ($self, $owner_id, $data) = @_;

    
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
        return;
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

    foreach my $ship (@{$self->ships}) {
        # No longer check for limits here, all done in the Ship module!
            
        # Calculate the final position based on thrust and direction
        my $distance = $ship->speed * $duration_millisec / 1000;
        my $delta_x = $distance * cos($ship->direction);
        my $delta_y = $distance * sin($ship->direction);
        my $end_x = int($ship->x + $delta_x);
        my $end_y = int($ship->y + $delta_y);
    
        # check for limits.
        $end_x = $self->width   if $end_x > $self->width;
        $end_x = 0              if $end_x < 0;
        $end_y = $self->height  if $end_y > $self->height;
        $end_y = 0              if $end_y < 0;
    
        # Check for collisions, in which case come to an early halt
    
        # Check for hits by missiles. In which case cause damage
    
        $ship->x($end_x);
        $ship->y($end_y);
   
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



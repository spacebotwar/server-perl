package Arena;

# An arena contaning many ships

use Moose;
use Ship;
use namespace::autoclean;
use Data::Dumper;

use constant PI => 3.14159;

# An array of all the ships in the Arena
#
has 'ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[Ship]',
    default => sub { [] },
);
# Number of ships in the Arena (temp)
#
has 'max_ships' => (
    is      => 'rw',
    isa     => 'Int',
    default => 4,
);
# The width of the arena (in pixels)
#
has 'width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);
# The height of the arena (in pixels)
#
has 'height' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);
# The 'time' (in seconds) from when the Tournament was started
# 
has 'start_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
has 'end_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
# The duration (in milliseconds) from each calculation
#
has 'duration' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);

# Create an Arena with random ships
#
sub BUILD {
    my ($self) = @_;

    my $max_ships = $self->max_ships;
    $max_ships = 100 if $max_ships > 100;

    my @ships;
    for (my $i=0; $i < $self->max_ships; $i++) {
        my $start_x = int(rand(400) + 200);
        my $start_y = int(rand(400) + 200);
        my $speed   = 30;
        my $direction   = rand(PI * 2);

        my $ship = Ship->new({
            id              => $i,
            owner_id        => $i % 2,
            type            => 'ship',
            x               => $start_x,
            y               => $start_y,
            thrust_forward  => $speed,
            orientation     => $direction,
            rotation        => 0,
        });
        print STDERR "CREATE SHIP: [".$ship->x."][".$ship->y."][".$ship->orientation."]\n";
        push @ships, $ship;
    }
    $self->ships(\@ships);
    $self->update($self->duration);
}

# Update the arena by a number of milliseconds
sub update {
    my ($self, $duration) = @_;

    print STDERR "DURATION: $duration\n";
    my $duration_millisec = $duration * 100;
    if ($self->start_time < 0) {
        # then this is the first time.
        $self->start_time(0);
        $self->end_time($duration_millisec);
    }
    else {
        $self->start_time($self->start_time + $duration_millisec);
        $self->end_time($self->end_time + $duration_millisec);
    }
    # this is only temporary until we have some 'external' control programs.
    # 'drukards walk'
    # This is equivalent to what the players program will request
    # Which means only the thrust and rotation can be set here
    #
    # In practice, on each tick, we give the current actual position of all
    # ships and the thrust and rotation (as we currently know it)
    #
    # During the next tick, each ship's new thrust and rotation will be received
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
        my ($rotation, $thrust_forward, $thrust_sideway, $thrust_reverse) = (0,0,0,0);

        my $start_x = $ship->x;
        my $start_y = $ship->y;
        my $end_x = $start_x;
        my $end_y = $start_y;
        
        my $start_orientation = $ship->orientation;

        # Move the required distance
        my $distance = $ship->speed * $duration_millisec / 1000;
        my $delta_x = $distance * cos($ship->direction);
        my $delta_y = $distance * sin($ship->direction);
        $end_x = int($start_x + $delta_x);
        $end_y = int($start_y + $delta_y);

        my $on_edge = 0;
        if ($end_x > $self->width - 100 and ($ship->orientation < PI/2 or $ship->orientation > 3*PI/2)) {
            $on_edge = 1;
        }
        if ($end_x < 100 and $ship->orientation > PI/2 and $ship->orientation < 3*PI/2) {
            $on_edge = 1;
        }
        if ($end_y > $self->height - 100 and $ship->orientation < PI) {
            $on_edge = 1;
        }
        if ($end_y < 100 and $ship->orientation > PI) {
            $on_edge = 1;
        }
        if ($on_edge) {
            $thrust_forward = 0;
        }
        else {
            $thrust_forward = $ship->max_thrust_forward;
        }

        my $delta_rotation;
        if ($on_edge) {
            $delta_rotation = $ship->id % 2 ? PI/8 : 0-PI/8;
        }
        else {
            $delta_rotation = rand(PI/2) - PI/4;
        }
        my $end_orientation = $ship->orientation + $delta_rotation;

        $rotation = ($end_orientation - $start_orientation) / ($duration_millisec / 1000);

        # Set the values
        $ship->rotation($rotation);
        $ship->thrust_forward($thrust_forward);
        $ship->thrust_reverse($thrust_reverse);
        $ship->thrust_sideway($thrust_sideway);
    }
    # This is where the server interprets these player request and adjusts them
    # to ensure they do not break game rules
    #
    foreach my $ship (@{$self->ships}) {
        # Safety net
        $ship->thrust_forward($ship->max_thrust_forward) if $ship->thrust_forward > $ship->max_thrust_forward;
        $ship->thrust_sideway($ship->max_thrust_sideway) if $ship->thrust_sideway > $ship->max_thrust_sideway;
        $ship->thrust_reverse($ship->max_thrust_reverse) if $ship->thrust_reverse > $ship->max_thrust_reverse;
        $ship->rotation($ship->max_rotation) if $ship->rotation > $ship->max_rotation;
        $ship->rotation(0-$ship->max_rotation) if $ship->rotation < 0-$ship->max_rotation;

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


# Create a hash representation of the object
#
sub to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->to_hash;
    }
    return {
        width   => $self->width,
        height  => $self->height,
        time    => $self->start_time,
        ships   => \@ships_ref,
    };
}

__PACKAGE__->meta->make_immutable;



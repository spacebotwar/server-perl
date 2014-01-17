package SpaceBotWar::Game::Ship;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

# This defines the basic characteristics of a ship

use constant PI => 3.14159;

# The unique ID of the ship
has 'id' => (
    is          => 'ro',
    writer      => '_id',
    isa         => 'Int',
    required    => 1,
);
# The ID of the ships owner
has 'owner_id' => (
    is          => 'ro',
    writer      => '_owner_id',
    isa         => 'Int',
    required    => 1,
);
# The name of the ship
has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ship',
);
# The type of the ship, e.g. 'battleship'
has 'type' => (
    is          => 'ro',
    isa         => 'Str',
    default     => 'ship',
);
# The status of the ship, e.g. 'ok' or 'dead'.
has 'status' => (
    is          => 'ro',
    writer      => '_status',
    isa         => 'Str',
    default     => 'ok',
);
# The health of the ship (0 to 100)
has 'health' => (
    is          => 'ro',
    writer      => '_health',
    isa         => 'Int',
    default     => 100,
);
# Current X co-ordinate
has 'x' => (
    is          => 'ro',
    writer      => '_x',
    isa         => 'Num',
    default     => 0,
);
# Current Y co-ordinate
has 'y' => (
    is          => 'ro',
    writer      => '_y',
    isa         => 'Num',
    default     => 0,
);
# Rotation rate of ship (radians per second)
# +ve = 
has 'rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 1,
);
# Current orientation of travel (in radians)
has 'orientation' => (
    is          => 'rw',
    writer      => 'orientation',
    isa         => 'Num',
    default     => 0,
);
# Forward thruster speed
has 'thrust_forward' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Side thruster speed
# +ve = thrust to the left
# -ve = thrust to the right
# 'put your hands on your hips'
#
has 'thrust_sideway' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Reverse thruster speed
has 'thrust_reverse' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Max forward speed of ship
has 'max_thrust_forward' => (
    is          => 'ro',
    isa         => 'Num',
    default     => 60,
);
# Max sideway speed of ship (note may also be negative)
# Absolute value
#
has 'max_thrust_sideway' => (
    is          => 'ro',
    isa         => 'Num',
    default     => 20,
);
# Max reverse speed of ship
has 'max_thrust_reverse' => (
    is          => 'ro',
    isa         => 'Num',
    default     => 30,
);
# Max rotational speed (radians per second)
has 'max_rotation' => (
    is          => 'ro',
    isa         => 'Num',
    default     => 2,
);

# log4perl logger
# TODO We will have to look at directing log info to a location
# where it can be sent back to the user, not to a system log file
# 
has log => (
    is        => 'ro',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
);

# Limit the requested thrust in any direction
# 
for my $direction (qw(forward reverse)) {
    around "thrust_$direction" => sub {
        my ($orig,$self,$speed) = @_;

        return $self->$orig unless defined $speed;
        
        my $max_method = "max_thrust_$direction";
        if ($speed > $self->$max_method) {
            $speed = $self->$max_method;
        }
        if ($speed < 0) {
            $speed = 0;
        }
        $self->$orig($speed);
    };
}
# Limit the sideways thrust
#
around 'thrust_sideway' => sub {
    my ($orig, $self, $speed) = @_;

    return $self->$orig unless defined $speed;

#    $self->log->debug("thrust_sideways = $speed");
    my $max_speed = $self->max_thrust_sideway;
    if ($speed > $max_speed) {
        $speed = $max_speed;
    }
    elsif ($speed < - $max_speed) {
        $speed = - $max_speed;
    }
    $self->$orig($speed);
};

# Limit the rotational speed
#
around "rotation" => sub {
    my ($orig, $self, $speed) = @_;

    return $self->$orig unless defined $speed;

    if ($speed > $self->max_rotation) {
        $speed = $self->max_rotation;
    }
    if ($speed < 0-$self->max_rotation) {
        $speed = 0-$self->max_rotation;
    }
    $self->$orig($speed);
};

# Normalise the orientation
#
around 'orientation' => sub {
    my ($orig, $self, $angle) = @_;

    # this should almost never happen, since this is the writer...
    $self->log->debug("Angle is [$angle]");
    return $self->$orig unless defined $angle;

    while ($angle > 2*PI) {
        $angle -= 2*PI;
    }
    while ($angle < 0) {
        $angle += 2*PI;
    }
    $self->$orig($angle);
};

sub asin {
    my ($val) = @_;
    return atan2($val, sqrt(1 - $val * $val));
}

# The direction the ship goes is determined by several factors
#  the 'orientation' of the ship, i.e. which direction it is facing
#  the 'thrust_forward' this being the main engine of the ship
#  the 'thrust_sideway' ships can use minor thrusters to move sideway
#  the 'thrust_reverse' which counters the main engine if used at the same time
#
sub direction {
    my ($self) = @_;

    my $forward = $self->thrust_forward - $self->thrust_reverse;
    my $delta_theta = atan2($self->thrust_forward, $self->thrust_sideway);
    my $direction = $self->orientation + $delta_theta;
    return $direction;
}

# Speed is a vector of forward,reverse & sideway thrust
#
sub speed {
    my ($self) = @_;

    my $forward = $self->thrust_forward - $self->thrust_reverse;
    my $speed = sqrt($forward * $forward + $self->thrust_sideway * $self->thrust_sideway);
    return $speed;
}

# Return the value in so many significant points
# TODO Replace this with Math::Round
#
sub decpoint {
    my ($value, $points) = @_;

    return int($value * 10) / 10;
}


# Create a hash representation of the object. For efficiency
# just use this to transmit the data once, and cache the static
# bits. From then use the 'dynamic_to_hash' method call.
#

# TODO We should look at doing this with 'augment'.
sub all_to_hash {
    my ($self) = @_;

    return {
        id                  => $self->id,
        owner_id            => $self->owner_id,
        x                   => decpoint($self->x),
        y                   => decpoint($self->y),
        direction           => decpoint($self->direction),
        speed               => decpoint($self->speed),
        rotation            => decpoint($self->rotation),
        orientation         => decpoint($self->orientation),
        max_rotation        => decpoint($self->max_rotation),
        max_thrust_forward  => decpoint($self->max_thrust_forward),
        max_thrust_sideway  => decpoint($self->max_thrust_sideway),
        max_thrust_reverse  => decpoint($self->max_thrust_reverse),
        name                => $self->name,
        type                => $self->type,
        status              => $self->status,
        health              => $self->health,
    };
}

# Give the ship status only as a hash
# This is a cut-down version which is more efficient to broadcast
# on the basis that the 'fixed' information has previously been
# transmitted from the 'all_to_hash' method
#
sub dynamic_to_hash {
    my ($self) = @_;

    #TODO TODO TODO
    #THIS IS TEST CODE ONLY, REMOVE BEFORE PRODUCTION!
    $self->x($self->x + 1);
    $self->y($self->y - 2);
    $self->orientation($self->orientation - 0.1);



    return {
        id              => $self->id,
        owner_id        => $self->owner_id,
        x               => decpoint($self->x),
        y               => decpoint($self->y),
        direction       => decpoint($self->direction),
        speed           => decpoint($self->speed),
        rotation        => decpoint($self->rotation),
        orientation     => decpoint($self->orientation),
        status          => $self->status,
        health          => $self->health,
    };
}




# Note we should probably add the following
#  shield_against_projectiles
#  shield_against_explosives
#  shield_against_lasers
#  armour_against_projectiles
#  armour_against_explosives
#  armour_against_lasers
#  weapons



__PACKAGE__->meta->make_immutable;

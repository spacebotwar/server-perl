package Ship;

use Moose;
use namespace::autoclean;

# This defines the basic characteristics of a ship

use constant PI => 3.14159;

# The unique ID of the ship
has 'id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# The ID of the ships owner
has 'owner_id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# The name of the ship
has 'name' => (
    is          => 'rw',
    isa         => 'Str',
);
# The type of the ship, e.g. 'battleship'
has 'type' => (
    is          => 'rw',
    isa         => 'Str',
    required    => 1,
);
# The status of the ship, e.g. 'ok' or 'dead'.
has 'status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ok',
);
# The health of the ship (0 to 100)
has 'health' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 100,
);
# Current X co-ordinate
has 'x' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);
# target X co-ordinate (at end of tick)
has 'target_x' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);
# Current Y co-ordinate
has 'y' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);
# target Y co-ordinate (at end of tick)
has 'target_y' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);
# Rotation rate of ship (radians per second)
has 'rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 1,
);
# Current orientation of travel (in radians)
has 'orientation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Target orientation of travel (in radians) (at end of tick)
has 'target_orientation' => (
    is          => 'rw',
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
    is          => 'rw',
    isa         => 'Num',
    default     => 60,
);
# Max sideway speed of ship
has 'max_thrust_sideway' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 10,
);
# Max reverse speed of ship
has 'max_thrust_reverse' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 20,
);
# Max rotational speed (radians per second)
has 'max_rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 2,
);

# Limit the requested thrust in any direction
# 
for my $direction (qw(forward sideway reverse)) {
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
    my $delta_theta = asin($self->thrust_sideway);
    my $direction = $self->orientation + $delta_theta;
    return $direction;
}

# Speed is a vector of forward & sideway thrust
#
sub speed {
    my ($self) = @_;

    my $forward = $self->thrust_forward - $self->thrust_reverse;
    my $speed = sqrt($forward * $forward + $self->thrust_sideway * $self->thrust_sideway);
}

# Create a hash representation of the object
#
sub to_hash {
    my ($self) = @_;

    return {
        id              => $self->id,
        owner_id        => $self->owner_id,
        x               => $self->x,
        y               => $self->y,
        direction       => $self->direction,
        speed           => $self->speed,
        rotation        => $self->rotation,
        orientation     => $self->orientation,
        max_rotation    => $self->max_rotation,
        name            => $self->name,
        type            => $self->type,
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

package SpaceBotWar::Game::Ship;

use Moose;
use Data::Dumper;
use Math::Round qw(nearest);
use POSIX qw(fmod);
#use SpaceBotWar::Game::Missile;
use Test::More;

use namespace::autoclean;

extends 'SpaceBotWar::Game';

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
    default     => 'ship',
);
# The type of the ship, e.g. 'battleship'
has 'type' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ship',
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
    isa         => 'Num',
    default     => 0,
);
# Current Y co-ordinate
has 'y' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Rotation rate of ship (radians per second)
# +ve = 
has 'rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Current orientation of travel (in radians)
has 'orientation' => (
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
    is          => 'rw',
    isa         => 'Num',
    default     => 60,
);
# Max sideway speed of ship (note may also be negative)
# Absolute value
#
has 'max_thrust_sideway' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 20,
);
# Max reverse speed of ship
has 'max_thrust_reverse' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 30,
);
# Max rotational speed (radians per second)
has 'max_rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 2,
);
# Flag to launch a missile
has 'missile_launch' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);
# Direction to fire missile
has 'missile_direction' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Missile reload period
has 'missile_reloading' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

before 'normalize_radians' => sub {};

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

    my $max_speed = $self->max_thrust_sideway;
    if ($speed > $max_speed) {
        $speed = $max_speed;
    }
    elsif ($speed < 0 - $max_speed) {
        $speed = 0 - $max_speed;
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

# Normalise methods that are given an angle
#
for my $method (qw(orientation missile_direction)) {
    around $method => sub {
        my ($orig, $self, $angle) = @_;

        return $self->$orig if not defined $angle;

        $angle = $self->normalize_radians($angle);
        $self->$orig($angle);
    };
}

sub log {
    my ($self) = @_;
    my $log = Log::Log4perl->get_logger( __PACKAGE__ );
    return $log;
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
    my $delta_theta = atan2($self->thrust_sideway, $forward);
    my $direction = $self->orientation + $delta_theta;
    $direction = $self->normalize_radians($direction);
    return $direction;
};

# Speed is a vector of forward,reverse & sideway thrust
#
sub speed {
    my ($self) = @_;

    my $forward = $self->thrust_forward - $self->thrust_reverse;
    my $speed = sqrt($forward * $forward + $self->thrust_sideway * $self->thrust_sideway);
    return $speed;
};

# Tell the ship to fire a missile at the start of the next tick
# specify the angle in Arena absolute terms (not relative to the ship)
# Note. the direction must be within the angle of fire of the ship
# if not, it will be range limited
#
sub fire_missile_absolute {
    my ($self, $angle) = @_;

    my $relative_angle = $angle - $self->orientation;
    $relative_angle = $self->normalize_radians($relative_angle);

    return $self->fire_missile_relative($relative_angle);
}


# Tell the ship to fire a missile relative to the ships orientation
# (will accept an angle plus/minus 45 degrees)
# returns 'undef' if the missile is not ready to fire
# returns the direction the missile was aimed otherwise
#
sub fire_missile_relative {
    my ($self, $relative_angle) = @_;

    if ($relative_angle > PI/4) {
        $relative_angle = PI/4;
    }
    if ($relative_angle < 0 - PI/4) {
        $relative_angle = 0 - PI/4;
    }
    my $angle = $self->orientation + $relative_angle;
    if ($self->missile_reloading) {
        return;
    }
    $self->missile_direction($angle);
    $self->missile_launch(1);
}

# Launch a missile, if required
# Returns a missile object or undef if there is no missile to fire
#
#sub open_fire {
#    my ($self, $id) = @_;
#
#    return unless $self->missile_launch;
#
#    my $missile = SpaceBotWar::Game::Missile->new({
#        id              => $id,
#        owner_id        => $self->owner_id,
#        x               => $self->x,
#        y               => $self->y,
#        direction       => $self->missile_direction,
#        status          => 'launch',
#    });
#    $self->missile_launch(0);
#    $self->missile_reloading(10);       # about 5 seconds
#    return $missile;
#}


# Create a hash representation of the object. For efficiency
# just use this to transmit the data once, and cache the static
# bits. From then use the 'dynamic_to_hash' method call.
#
sub all_to_hash {
    my ($self) = @_;

    return {
        id                  => $self->id,
        owner_id            => $self->owner_id,
        x                   => nearest(0.1, $self->x),
        y                   => nearest(0.1, $self->y),
        direction           => nearest(0.01, $self->direction),
        speed               => nearest(0.1, $self->speed),
        thrust_forward      => nearest(0.1, $self->thrust_forward),
        thrust_sideway      => nearest(0.1, $self->thrust_sideway),
        thrust_reverse      => nearest(0.1, $self->thrust_reverse),
        rotation            => nearest(0.01, $self->rotation),
        orientation         => nearest(0.01, $self->orientation),
        max_rotation        => nearest(0.1, $self->max_rotation),
        max_thrust_forward  => nearest(0.1, $self->max_thrust_forward),
        max_thrust_sideway  => nearest(0.1, $self->max_thrust_sideway),
        max_thrust_reverse  => nearest(0.1, $self->max_thrust_reverse),
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

    return {
        id              => $self->id,
        owner_id        => $self->owner_id,
        x               => nearest(0.1, $self->x),
        y               => nearest(0.1, $self->y),
        direction       => nearest(0.01, $self->direction),
        speed           => nearest(0.1, $self->speed),
        rotation        => nearest(0.01, $self->rotation),
        orientation     => nearest(0.01, $self->orientation),
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



#__PACKAGE__->meta->make_immutable;
1;

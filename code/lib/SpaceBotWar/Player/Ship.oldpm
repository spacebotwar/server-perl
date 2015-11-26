package SpaceBotWar::Player::Ship;

use strict;
use warnings;

use parent 'SpaceBotWar::Player';

use SpaceBotWar;
use SpaceBotWar::Player::Missile;

use Data::Dumper;
use Math::Round qw(nearest);
use POSIX qw(fmod);

# This defines the basic characteristics of a ship

use constant PI => 3.14159;

# The unique ID of the ship
sub id {
    my $self = shift;
    if (@_) {
        $self->{id} = $_[0];
    }
    return $self->{id};
}


# The ID of the ships owner
sub owner_id {
    my $self = shift;
    if (@_) {
        $self->{owner_id} = $_[0];
    }
    return $self->{owner_id};
}


# The name of the ship
sub name {
    my $self = shift;
    if (@_) {
        $self->{name} = $_[0];
    }
    return $self->{name};
}

# The type of the ship, e.g. 'battleship'
sub type {
    my $self = shift;
    if (@_) {
        $self->{type} = $_[0];
    }
    return $self->{type};
}

# The status of the ship, e.g. 'ok' or 'dead'.
sub status {
    my $self = shift;
    if (@_) {
        $self->{status} = $_[0];
    }
    return $self->{status};
}

# The health of the ship (0 to 100)
sub health {
    my $self = shift;
    if (@_) {
        $self->{health} = $_[0];
    }
    return $self->{health};
}

# Current X co-ordinate
sub x {
    my $self = shift;
    if (@_) {
        $self->{x} = $_[0];
    }
    return $self->{x};
}

# Current Y co-ordinate
sub y {
    my $self = shift;
    if (@_) {
        $self->{y} = $_[0];
    }
    return $self->{y};
}

# Rotation rate of ship (radians per second)
# +ve = 
sub rotation {
    my $self = shift;
    if (@_) {
        my $speed = $self->_limit($_[0], 0 - $self->max_rotation, $self->max_rotation);
        $self->{rotation} = $speed;
    }
    return $self->{rotation};
}

# Current orientation of travel (in radians)
sub orientation {
    my $self = shift;
    if (@_) {
        $self->{orientation} = $self->normalize_radians($_[0]);
    }
    return $self->{orientation};
}


# Forward thruster speed
sub thrust_forward {
    my $self = shift;
    if (@_) {
        my $speed = $self->_limit($_[0], 0, $self->max_thrust_forward);
        $self->{thrust_forward} = $speed;
    }
    return $self->{thrust_forward};
}

# Side thruster speed
# +ve = thrust to the left
# -ve = thrust to the right
# 'put your hands on your hips'
#
sub thrust_sideway {
    my $self = shift;
    if (@_) {
        my $speed = $self->_limit($_[0], 0 - $self->max_thrust_sideway, $self->max_thrust_sideway);
        $self->{thrust_sideway} = $speed;
    }
    return $self->{thrust_sideway};
}

# Reverse thruster speed
sub thrust_reverse {
    my $self = shift;
    if (@_) {
        my $speed = $self->_limit($_[0], 0, $self->max_thrust_reverse);
        $self->{thrust_reverse} = $speed;
    }
    return $self->{thrust_reverse};
}

# Max forward speed of ship
sub max_thrust_forward {
    my $self = shift;
    if (@_) {
        $self->{max_thrust_forward} = $_[0];
    }
    return $self->{max_thrust_forward};
}

# Max sideway speed of ship (note may also be negative)
# Absolute value
#
sub max_thrust_sideway {
    my $self = shift;
    if (@_) {
        $self->{max_thrust_sideway} = $_[0];
    }
    return $self->{max_thrust_sideway};
}

# Max reverse speed of ship
sub max_thrust_reverse {
    my $self = shift;
    if (@_) {
        $self->{max_thrust_reverse} = $_[0];
    }
    return $self->{max_thrust_reverse};
}


# Max rotational speed (radians per second)
sub max_rotation {
    my $self = shift;
    if (@_) {
        $self->{max_rotation} = $_[0];
    }
    return $self->{max_rotation};
}

# Flag to launch a missile
sub missile_launch {
    my $self = shift;
    if (@_) {
        $self->{missile_launch} = $_[0];
    }
    return $self->{missile_launch};
}

# Direction to fire missile
sub missile_direction {
    my $self = shift;
    if (@_) {
        $self->{missile_direction} = $self->normalize_radians($_[0]);
    }
    return $self->{missile_direction};
}

# Missile reload period
sub missile_reloading {
    my $self = shift;
    if (@_) {
        $self->{missile_reloading} = $_[0];
    }
    return $self->{missile_reloading};
}

sub new {
    my ($class, $args) = @_;

    die "id is a required argument" unless defined $args->{id};
    die "owner_id is a required argument" unless defined $args->{owner_id};

    my $self = bless {
        id                      => $args->{id},
        owner_id                => $args->{owner_id},
    }, $class;
    $self->initialize($args);
    return $self;
}

# Initialization code
#
sub initialize {
    my ($self, $args) = @_;

    print STDERR "#### initialize: \n";
    # Specify default values
    #
    $self->name($self->name // 'ship');
    $self->type($self->type // 'type');
    $self->status($self->status // 'launch');
    $self->health($self->health // 100);
    $self->x($self->x // 0);
    $self->y($self->y // 0);
    $self->max_thrust_forward($self->max_thrust_forward // 60);
    $self->max_thrust_sideway($self->max_thrust_sideway // 20);
    $self->max_thrust_reverse($self->max_thrust_reverse // 30);
    $self->max_rotation($self->max_rotation // 2);
    $self->rotation($self->rotation // 0);
    $self->orientation($self->orientation // 0);
    $self->thrust_forward($self->thrust_forward // 0);
    $self->thrust_sideway($self->thrust_sideway // 0);
    $self->thrust_reverse($self->thrust_reverse // 0);
    $self->missile_launch(0);
    $self->missile_direction(0);
    $self->missile_reloading(0);
}

# Limit a value between two numbers
#
sub _limit {
    my ($self, $speed, $lower, $higher) = @_;

    $speed = $higher if $speed > $higher;
    $speed = $lower if $speed < $lower;
    return $speed;
}

# The direction the ship goes is determined by several factors
#  the 'orientation' of the ship, i.e. which direction it is facing
#  the 'thrust_forward' this being the main engine of the ship
#  the 'thrust_sideway' ships can use minor thrusters to move sideway
#  the 'thrust_reverse' which counters the main engine if used at the same time
#
sub direction {
    my ($self) = @_;

    return $self->actual_direction($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse, $self->orientation);
}

sub actual_direction {
    my ($self, $thrust_forward, $thrust_sideway, $thrust_reverse, $orientation) = @_;

    my $forward = $thrust_forward - $thrust_reverse;
    my $delta_theta = atan2($thrust_sideway, $thrust_forward);
    my $direction = $orientation + $delta_theta;
    return $direction;
}

# Speed is a vector of forward,reverse & sideway thrust
#
sub speed {
    my ($self) = @_;

    return $self->actual_speed($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse);
}

sub actual_speed {
    my ($self, $thrust_forward, $thrust_sideway, $thrust_reverse) = @_;

    my $forward = $thrust_forward - $thrust_reverse;
    my $speed = sqrt($forward * $forward + $thrust_sideway * $thrust_sideway);
    return $speed;
}

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
sub open_fire {
    my ($self, $id) = @_;

    return unless $self->missile_launch;

    my $missile = SpaceBotWar::Player::Missile->new({
        id              => $id,
        owner_id        => $self->owner_id,
        x               => $self->x,
        y               => $self->y,
        direction       => $self->missile_direction,
        status          => 'launch',
    });
    $self->missile_launch(0);
    $self->missile_reloading(10);       # about 5 seconds
    return $missile;
}


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

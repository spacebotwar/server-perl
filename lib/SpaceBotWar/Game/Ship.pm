package SpaceBotWar::Game::Ship;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use Log::Log4perl;

use namespace::autoclean;

# This defines the basic characteristics of a ship

use constant PI => 3.14159;

# The unique ID of the ship
has '_id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    traits      => [qw/Private/],
);
# The ID of the ships owner
has '_owner_id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
    traits      => [qw/Private/],
);
# The name of the ship
has '_name' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ship',
    traits      => [qw/Private/],
);
# The type of the ship, e.g. 'battleship'
has '_type' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ship',
    traits      => [qw/Private/],
);
# The status of the ship, e.g. 'ok' or 'dead'.
has '_status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ok',
    traits      => [qw/Private/],
);
# The health of the ship (0 to 100)
has '_health' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 100,
    traits      => [qw/Private/],
);
# Current X co-ordinate
has '_x' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Current Y co-ordinate
has '_y' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Rotation rate of ship (radians per second)
# +ve = 
has 'rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 1,
);
# Current orientation of travel (in radians)
has '_orientation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Forward thruster speed
has '_thrust_forward' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Side thruster speed
# +ve = thrust to the left
# -ve = thrust to the right
# 'put your hands on your hips'
#
has '_thrust_sideway' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Reverse thruster speed
has '_thrust_reverse' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
    traits      => [qw/Private/],
);
# Max forward speed of ship
has '_max_thrust_forward' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 60,
    traits      => [qw/Private/],
);
# Max sideway speed of ship (note may also be negative)
# Absolute value
#
has '_max_thrust_sideway' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 20,
    traits      => [qw/Private/],
);
# Max reverse speed of ship
has '_max_thrust_reverse' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 30,
    traits      => [qw/Private/],
);
# Max rotational speed (radians per second)
has '_max_rotation' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 2,
    traits      => [qw/Private/],
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


before rotation => sub {
    my ($self) = @_;

    $self->log->debug("::Ship->rotation");
};

# during construction, rename the public attribute names to the private names.
# 
around BUILDARGS => sub {
    my ($orig, $class, $args) = @_;

    # Convert public to private
    #
    for my $method (qw(id name owner_id x y health status max_thrust_forward max_thrust_sideway max_thrust_reverse type orientation max_rotation)) {
        if (defined $args->{$method}) {
            $args->{"_".$method} = $args->{$method};
            delete $args->{$method};
        }
    }
    return $class->$orig($args);
};

# Add read-only accessors for the private ones
#
for my $method (qw(id name owner_id x y health status max_thrust_forward max_thrust_sideway max_thrust_reverse type orientation max_rotation)) {
    __PACKAGE__->meta->add_method($method => sub {
        my ($self, $arg) = @_;
        die "Cannot write to [$method]" if defined $arg;
        my $private_method = "_".$method;
        return $self->$private_method;
    })
}

# Add some read-write accessors that can then be overridden
#
for my $method (qw(thrust_forward thrust_sideway thrust_reverse)) {
    __PACKAGE__->meta->add_method($method => sub {
        my $self = shift;
        my $private_method = "_$method";
        return $self->$private_method(@_);
    });
}

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
around '_orientation' => sub {
    my ($orig, $self, $angle) = @_;

    return $self->$orig if not defined $angle;

    while ($angle > 2*PI) {
        $angle -= 2*PI;
    }
    while ($angle < 0) {
        $angle += 2*PI;
    }
    $self->$orig($angle);
};

# The direction the ship goes is determined by several factors
#  the 'orientation' of the ship, i.e. which direction it is facing
#  the 'thrust_forward' this being the main engine of the ship
#  the 'thrust_sideway' ships can use minor thrusters to move sideway
#  the 'thrust_reverse' which counters the main engine if used at the same time
#
sub direction {
    my ($self, $args) = @_;

    if (defined $args) {
        die "Cannot write to [direction]";
    }
    my $forward = $self->_thrust_forward - $self->_thrust_reverse;
    my $delta_theta = atan2($self->_thrust_forward, $self->_thrust_sideway);
    my $direction = $self->orientation + $delta_theta;
    return $direction;
}

# Speed is a vector of forward,reverse & sideway thrust
#
sub speed {
    my ($self, $args) = @_;

    if (defined $args) {
        die "Cannot write to [speed]";
    }
    my $forward = $self->_thrust_forward - $self->_thrust_reverse;
    my $speed = sqrt($forward * $forward + $self->_thrust_sideway * $self->_thrust_sideway);
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

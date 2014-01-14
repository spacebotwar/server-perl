package SpaceBotWar::Game::Ship::Enemy;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

extends 'SpaceBotWar::Game::Ship';

# Rotation rate of ship (radians per second)
# +ve = 
has 'rotation' => (
    is          => 'ro',
    isa         => 'Num',
    writer      => '_rotation',
    default     => 1,
);

# Forward thruster speed
has 'thrust_forward' => (
    is          => 'bare',
    isa         => 'Num',
    writer      => '_thrust_forward',
    default     => 0,
);
# Side thruster speed
# +ve = thrust to the left
# -ve = thrust to the right
# 'put your hands on your hips'
#
has 'thrust_sideway' => (
    is          => 'bare',
    isa         => 'Num',
    writer      => '_thrust_sideway',
    default     => 0,
);
# Reverse thruster speed
has 'thrust_reverse' => (
    is          => 'bare',
    isa         => 'Num',
    writer      => '_thrust_reverse',
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
    $self->_orientation($self->orientation - 0.1);



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

package SpaceBotWar::Player::Missile;

use strict;
use warnings;

use Class::Accessor 'antlers';

extends 'SpaceBotWar::Player';

use Data::Dumper;
use Math::Round qw(nearest);

# This defines the basic characteristics of a missile

use constant PI => 3.14159;

# The unique ID of the missile
has 'id' => ( is => 'ro');

# The ID of the ships owner
has 'owner_id' => (is => 'ro');

# The type of the ship, e.g. 'fireball'
has 'type' => (is => 'ro');

# The status of the ship, e.g. 'ok' or 'dead'.
has 'status' => (is => 'rw');

# The health of the ship (0 to 100)
has 'health' => (is => 'rw');

# Current X co-ordinate
has 'x' => (is => 'rw');

# Current Y co-ordinate
has 'y' => (is => 'rw');

# Next X co-ordinate
has 'next_x' => (is => 'rw');

# Next Y co-ordinate
has 'next_y' => (is => 'rw');

# Forward speed
has 'speed' => (is => 'rw');

has 'direction' => (is => 'rw');

# Normalise the direction
#
sub direction {
    my ($self, $radians) = @_;

    return $self->_direction_accessor unless defined $radians;
    $radians = $self->normalize_radians($radians);
    $self->_direction_accessor($radians);
}

# Create a hash representation of the object.

sub all_to_hash {
    my ($self) = @_;

    return {
        id              => $self->id,
        owner_id        => $self->owner_id,
        x               => nearest(0.1, $self->x),
        y               => nearest(0.1, $self->y),
        direction       => nearest(0.01, $self->direction),
        speed           => nearest(0.01, $self->speed),
        status          => $self->status,
    };
}
1;


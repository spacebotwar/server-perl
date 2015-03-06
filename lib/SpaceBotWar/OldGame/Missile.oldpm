package SpaceBotWar::Game::Missile;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use Math::Round qw(nearest);

use namespace::autoclean;

extends "SpaceBotWar::Game";

# This defines the basic characteristics of a ship

use constant PI => 3.14159;

# The unique ID of the missile
has 'id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# The ID of the missiles owner
has 'owner_id' => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);
# The type of the missile, e.g. 'fireball'
has 'type' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'fireball',
);
# The status of the missile, e.g. 'ok' or 'explode'.
has 'status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'launch',
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
# Next X co-ordinate
has 'next_x' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Next Y co-ordinate
has 'next_y' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

# Forward speed
has 'speed' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
has 'direction' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 2,
);

# Normalise the direction
#
around 'direction' => sub {
    my ($orig, $self, $angle) = @_;

    return $self->$orig if not defined $angle;

    $angle = $self->normalize_radians($angle);
    $self->$orig($angle);
};

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

__PACKAGE__->meta->make_immutable;

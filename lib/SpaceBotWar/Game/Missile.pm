package SpaceBotWar::Game::Missile;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use Log::Log4perl;

use namespace::autoclean;

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
    default     => 'ship',
);
# The status of the missile, e.g. 'ok' or 'explode'.
has 'status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ok',
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

};

# Normalise the direction
#
around 'direction' => sub {
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

# Create a hash representation of the object.

sub all_to_hash {
    my ($self) = @_;

    return {
        id              => $self->id,
        owner_id        => $self->owner_id,
        x               => decpoint($self->x),
        y               => decpoint($self->y),
        direction       => decpoint($self->direction),
        speed           => decpoint($self->speed),
        status          => $self->status,
    };
}

__PACKAGE__->meta->make_immutable;

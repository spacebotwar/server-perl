package SpaceBotWar::Game::Ship::Mine;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

# This defines the characteristics of a players own ship.
# A player can change some attributes of their own ship
# but not of the opponent
#
extends 'SpaceBotWar::Game::Ship';

# Create a hash representation of the object. For efficiency
# just use this to transmit the data once, and cache the static
# bits. From then use the 'dynamic_to_hash' method call.
#
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

__PACKAGE__->meta->make_immutable;

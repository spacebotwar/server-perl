package SpaceBotWar::Game::Ship::Enemy;

use Moose;
use MooseX::Privacy;

use Log::Log4perl;

use namespace::autoclean;

extends 'SpaceBotWar::Game::Ship';

# Make some of the attributes private
has ['+thrust_forward', '+thrust_reverse', '+thrust_sideway', '+rotation', '+max_thrust_forward','+max_thrust_sideway','+max_thrust_reverse','+max_rotation'] => (
    traits  => [qw/Protected/],
);

# Make some of the attributes read-only
#has ['+id', '+owner_id', '+name','+type','+status','+health','+x','+y','+orientation'] => (
#    is      => 'ro',
#);
# The above does not work...
#
for my $method ( qw(id owner_id name type status health x y orientation speed direction)) {
    before $method => sub {
        my $self = shift;
        if (@_) {
            die "Cannot write to [$method]";
        }
    };
}

# It seems a bit of a cludge doing this, I can't see how else to do it whilst retaining the benefit of 'protected' attributes.
#
sub speed {
    my ($self) = @_;

    return $self->actual_speed($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse);
}
sub direction {
    my ($self) = @_;

    return $self->actual_direction($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse, $self->orientation);
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

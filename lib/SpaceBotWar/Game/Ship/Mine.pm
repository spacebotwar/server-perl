package SpaceBotWar::Game::Ship::Mine;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

use constant PI => 3.14159;

# This defines the characteristics of a players own ship.
# A player can change some attributes of their own ship
# but not of the opponent
#
extends 'SpaceBotWar::Game::Ship';

# We need to make some attributes read-only so they can't be 
# changed by the player who owns the ships.
for my $method ( qw(id owner_id name type status health x y orientation speed direction max_rotation max_thrust_forward max_thrust_sideway max_thrust_reverse missile_reloading missile_launch missile_direction)) {
    before $method => sub {
        my $self = shift;
        if (@_) {
            die "Cannot write to [$method]";
        }
    };
}

# Why do we have to do this in order for 'Safe' to recognise it?
#
for my $method (qw(actual_speed speed thrust_forward thrust_sideway thrust_reverse rotation)) {
    before $method => sub {};
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

__PACKAGE__->meta->make_immutable;

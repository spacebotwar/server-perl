package SpaceBotWar::Game::Ship::Mine;

use Moose;
use MooseX::Privacy;

use namespace::autoclean;

use constant PI => 3.14159;

# This defines the characteristics of a players own ship.
# A player can change some attributes of their own ship
# but not of the opponent
#
extends 'SpaceBotWar::Game::Ship';

# We need to make some attributes read-only so they can't be 
# changed by the player who owns the ships.
for my $method ( qw(id owner_id name type status health x y orientation speed direction max_rotation max_thrust_forward max_thrust_sideway max_thrust_reverse)) {
    before $method => sub {
        my $self = shift;
        if (@_) {
            die "Cannot write to [$method]";
        }
    };
}

# Methods that we can't use in a subclass
#
sub open_fire { die "Cannot call this method"; }
sub missile_launch { die "Cannot call this method"; }
sub missile_direction { die "Cannot call this method"; }
sub missile_reloading { die "Cannot call this method"; }

# Why do we have to do this in order for 'Safe' to recognise it?
#
for my $method (qw(actual_speed speed thrust_forward thrust_sideway thrust_reverse rotation fire_missile_relative fire_missile_absolute normalize_radians missile_reloading)) {
    before $method => sub {};
}

#__PACKAGE__->meta->make_immutable;
1;

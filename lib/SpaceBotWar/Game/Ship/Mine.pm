package SpaceBotWar::Game::Ship::Mine;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

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

# Why do we have to do this in order for 'Safe' to recognise it?
#
for my $method (qw(actual_speed speed thrust_forward thrust_sideway thrust_reverse rotation)) {
    before $method => sub {};
}

__PACKAGE__->meta->make_immutable;

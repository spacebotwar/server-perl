use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Number::Delta;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::Game::Arena;
use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;

my $arena = SpaceBotWar::Game::Arena->new({});

isa_ok($arena, 'SpaceBotWar::Game::Arena', "Correct class");

is(scalar(@{$arena->ships}), 12, "Correct number of ships");

my $player_ships = grep {$_->owner_id == 1} @{$arena->ships};
is($player_ships, 6, "Correct number of ships for player 1");

is($arena->start_time, -1, "Initial start time is correct");

my ($ship) = grep {$_->id == 1} @{$arena->ships};
my $start_x = $ship->x;
my $start_y = $ship->y;
my $orientation = $ship->orientation;
my $rotation = $ship->rotation;

$arena->tick(5);

is($arena->start_time, -0.5, "Tick time is correct");

# A ship with zero thrust should have moved.

is($ship->x, $start_x, "Same X position");
is($ship->y, $start_y, "Same Y position");
is($ship->orientation, $orientation, "Same Orientation");
is($ship->rotation, $rotation, "Same Rotation");

# Lets rotate it for 1 second at 1 radian per second
$ship->orientation(0);
$ship->rotation(1);
$arena->tick(10);

# angle of rotation should be (roughly) 1 radian.
delta_ok($ship->orientation, 1, "Rotation is close enough");

# now for half a second
$ship->orientation(0);
$arena->tick(5);

delta_ok($ship->orientation, 0.5, "Rotation for half a second");

# now for half a second in the reverse direction
$ship->orientation(0);
$ship->rotation(-1);
$arena->tick(5);
delta_ok($ship->orientation, PI * 2 -0.5, "Clockwise rotation for half a second");

##### Now some tests for collisions ######
# (we just need two ships initially)
#
my @ships;
foreach my $ship_id (1,2) {
    my $ship = SpaceBotWar::Game::Ship->new({
        id              => $ship_id,
        owner_id        => $ship_id,
        x               => 0,
        y               => 0,
        thrust_forward  => 0,
        thrust_sideway  => 0,
        thrust_reverse  => 0,
        orientation     => 0,
        rotation        => 0,
    });
    push @ships, $ship;
}
$arena->ships(\@ships);

$arena->tick(5);

foreach my $ship (@{$arena->ships}) {
    diag "ID: ".$ship->id;
    diag "          x: ".$ship->x;
    diag "          y: ".$ship->y;
}


done_testing();

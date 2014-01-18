use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Exception;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::Game::Ship::Mine;


my $ship = SpaceBotWar::Game::Ship::Mine->new({
    id          => 0,
    owner_id    => 0,
});

isa_ok($ship, 'SpaceBotWar::Game::Ship::Mine', "Correct class");

# Check for defaults
foreach my $method (qw(thrust_forward thrust_sideway thrust_reverse x y)) {
    my $actual = $ship->$method;
    is($actual, 0, "$method is zero");
}

is($ship->rotation, 1, "rotation is one");
is($ship->health, 100, "health is 100");
is($ship->status, 'ok', "status is OK");
is($ship->max_thrust_forward,   60, "max thrust forward is 60");
is($ship->max_thrust_reverse,   30, "max thrust reverse is 30");
is($ship->max_thrust_sideway,   20, "max thrust sideway is 20");

# Check for attributes we are allowed to change
#
$ship->thrust_forward(50);
is($ship->thrust_forward, 50, "In range forward");
$ship->thrust_reverse(20);
is($ship->thrust_reverse, 20, "In range reverse");
is($ship->speed, 30, "Correct resultant speed");

$ship->thrust_forward(4);
$ship->thrust_reverse(0);
$ship->thrust_sideway(3);
is($ship->speed, 5, "3-4-5 triangle");

# full speed!

$ship->thrust_forward($ship->max_thrust_forward);
is($ship->thrust_forward, $ship->max_thrust_forward, "At max forward thrust");

$ship->thrust_sideway($ship->max_thrust_sideway);
is($ship->thrust_sideway, $ship->max_thrust_sideway, "At max sideway right thrust");

$ship->thrust_sideway(0 - $ship->max_thrust_sideway);
is($ship->thrust_sideway, 0 - $ship->max_thrust_sideway, "at max sideway left thrust");

# attempt warp factor!

$ship->thrust_reverse(99999999);
is($ship->thrust_reverse, $ship->max_thrust_reverse, "Ye canny break the (reverse) laws of physics!");

$ship->thrust_forward(99999999);
is($ship->thrust_forward, $ship->max_thrust_forward, "Ye canny break the (forward) laws of physics!");

$ship->thrust_sideway(99999999);
is($ship->thrust_sideway, $ship->max_thrust_sideway, "Ye canny break the (sideway) laws of physics!");

$ship->thrust_sideway(99999999);
is($ship->thrust_sideway, $ship->max_thrust_sideway, "Ye canny break the (sideway) laws of physics!");

$ship->thrust_sideway(-99999999);
is($ship->thrust_sideway, 0 - $ship->max_thrust_sideway, "Ye canny break the (negative sideway) laws of physics!");

# now check attributes we are *not* allowed to alter
foreach my $method (qw(owner_id type status health orientation  max_thrust_forward max_thrust_sideway max_thrust_reverse max_rotation x y)) {
    throws_ok {$ship->$method(0)} qr/Cannot write to \[$method\]/, "write to RO attribute [$method]";
}

throws_ok {$ship->id(0)}    qr/Cannot write to \[id\]/,       'Cannot write to [id]';
throws_ok {$ship->_id(0)}   qr/Attribute _id is private/,    'Cannot write to [_id]';
throws_ok {$ship->_id}      qr/Attribute _id is private/,   'Cannot read from [_id]';

done_testing();


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
use SpaceBotWar::Player::Ship;
use SpaceBotWar::Player::Ship::Mine;


my $ship = SpaceBotWar::Player::Ship->new({
    id          => 1,
    owner_id    => 1,
});

isa_ok($ship, 'SpaceBotWar::Player::Ship', "Correct class");
is($ship->max_thrust_forward, 60, "default max forward thrust");
is($ship->max_thrust_sideway, 20, "default max sideway thrust");
is($ship->max_thrust_reverse, 30, "default max reverse thrust");
is($ship->max_rotation, 2, "default max rotation");
is($ship->name, 'ship', "default ship name");

$ship->thrust_forward(100);
is($ship->thrust_forward, $ship->max_thrust_forward, "limit thrust forward");

$ship->thrust_reverse(100);
is($ship->thrust_reverse, $ship->max_thrust_reverse, "limit thrust reverse");

$ship->thrust_sideway(100);
is($ship->thrust_sideway, $ship->max_thrust_sideway, "limit thrust sideway");

$ship->rotation(100);
is($ship->rotation, $ship->max_rotation, "limit rotation");

$ship->missile_launch(11);
is($ship->missile_launch, 11, "Can set protected missile_launch");

$ship->normalize_radians(100);

diag("####----####");

my $test_ship = SpaceBotWar::Player::Ship::Mine->new({
    id          => 2,
    owner_id    => 2,
});


diag("THRUST-FORWARD: [".$test_ship->thrust_forward."]");
$test_ship->thrust_forward(100);

diag("THRUST-FORWARD: [".$test_ship->thrust_forward."]");

done_testing();





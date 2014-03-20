use 5.010;
use strict;
use feature "switch";
use lib '../lib';
use lib '../../lib';

use POSIX qw(fmod);

use SpaceBotWar;
use SpaceBotWar::Game::Ship;
use Test::More;

my $ship = SpaceBotWar::Game::Ship->new({
    id          => 1,
    owner_id    => 1,
});

$ship->thrust_forward(20);
$ship->rotation(0.2);
$ship->fire_missile_relative(0);

ok(1);
done_testing;

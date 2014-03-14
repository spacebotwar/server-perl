use 5.010;
use strict;
use feature "switch";
use lib '../lib';
use lib '../../lib';

use POSIX qw(fmod);

use SpaceBotWar;
use SpaceBotWar::Game::Ship;
use Test::More;
use Test::Number::Delta relative => 1e-3;

use constant PI => 3.14159;

my $p_angle = PI/4;
my $p2_angle = 3*PI/4;
my $n_angle = 0 - PI/4;
my $n2_angle = 0 - 3*PI/4;

my $ship = SpaceBotWar::Game::Ship->new({
    id          => 1,
    owner_id    => 1,
});

# Just to confirm that the POSIX fmod routine works for both +ve and -ve angles

foreach my $i (1..4) {
    # +ve angles
    my $f_angle = $ship->normalize_radians($p_angle + $i * 2 * PI);
    delta_ok($p_angle, $f_angle, "+ve going +ve Angles match $i");

    # -ve angles
    $f_angle = $ship->normalize_radians($n_angle - ($i * 2 * PI));
    delta_ok($n_angle, $f_angle, "-ve going -ve Angles match $i");

    # -ve going +ve
    $f_angle = $ship->normalize_radians($n_angle + ($i * 2 * PI));
    delta_ok($n_angle, $f_angle, "-ve going +ve Angles match $i");

    # +ve going -ve
    $f_angle = $ship->normalize_radians($p_angle - ($i * 2 * PI));
    delta_ok($p_angle, $f_angle, "+ve going -ve Angles match $i");

    # +ve angles
    $f_angle = $ship->normalize_radians($p2_angle + $i * 2 * PI);
    delta_ok($p2_angle, $f_angle, "2 +ve going +ve Angles match $i");

    # -ve angles
    $f_angle = $ship->normalize_radians($n2_angle - ($i * 2 * PI));
    delta_ok($n2_angle, $f_angle, "2 -ve going -ve Angles match $i");

    # -ve going +ve
    $f_angle = $ship->normalize_radians($n2_angle + ($i * 2 * PI));
    delta_ok($n2_angle, $f_angle, "2 -ve going +ve Angles match $i");

    # +ve going -ve
    $f_angle = $ship->normalize_radians($p2_angle - ($i * 2 * PI));
    delta_ok($p2_angle, $f_angle, "2 +ve going -ve Angles match $i");
}

ok(1);
done_testing;

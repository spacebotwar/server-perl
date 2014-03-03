use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;
use Safe;
use Safe::Hole;

use SpaceBotWar;
use SpaceBotWar::Game::Ship::Mine;



our $ship = SpaceBotWar::Game::Ship::Mine->new({
    id              => 1,
    owner_id        => 2,
    status          => 'ok',
    health          => 100,
    x               => 42,
    y               => 25,
    rotation        => 0.1,
    orientation     => 0.1,
    thrust_forward  => 3,
    thrust_sideway  => 4,
    thrust_reverse  => 5,
});
my $thrust_forward = 0;

$ship->thrust_forward(33);
diag "++++++ thrust_forward = [".$ship->thrust_forward."]";

my $compartment = new Safe;
my $hole = new Safe::Hole {};
$hole->wrap($ship, $compartment, '$ship');

$compartment->permit('rand','srand','require','caller');
$compartment->share('$ship');

my $test_code = <<'END';
    my $log = '';

#    $log .= "got here. thrust_forward=[$thrust_forward]\n";
#    $thrust_forward = 1;
#    $log .= "thrust_forward now=[$thrust_forward]\n";
    $log .= "ship = [$ship]\n";
    $ship->thrust_forward(10);
#    $ship->thrust_sideway(rand(10));
#    $ship->thrust_reverse(rand(20));
#    $ship->rotation(rand(2) - 1);
    $log;
END

my $result = $compartment->reval($test_code, 1);
if ($@) {
    die "Could not evaluate code ==================================== $@";
}
diag "----- result [\n$result\n] -------";
diag "ship->thrust_forward = [".$ship->thrust_forward."]";
diag "thrust_forward = [$thrust_forward]";
ok(1);
done_testing();


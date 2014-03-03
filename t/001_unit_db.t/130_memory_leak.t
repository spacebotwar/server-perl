use 5.010;
use strict;
use feature "switch";
use lib '../lib';
use lib '../../lib';
use SpaceBotWar;
use Test::More;
use Devel::Cycle;

use SpaceBotWar::Game::Ship::Mine;

use Data::Dumper;

diag("About to create");
sleep(10);

foreach (1..1000) {
    my $ship = SpaceBotWar::Game::Ship::Mine->new({
                id              => 1,
                owner_id        => 1,
                status          => 1,
                health          => 1,
                x               => 1,
                y               => 1,
                rotation        => 1,
                orientation     => 1,
                thrust_forward  => 1,
                thrust_sideway  => 1,
                thrust_reverse  => 1,
    });
}

#find_cycle($ship, sub {
#    my $path = shift;
#    foreach (@$path) {
#        my ($type,$index,$ref,$value) = @$_;
#        diag "Circular reference found while destroying object of type " .
#            ref($ship) . "! reftype: $type\n";
#        # print other diagnostics if needed; see docs for find_cycle()
#    }
#});

diag("created");
sleep(10);

ok(1);
done_testing;

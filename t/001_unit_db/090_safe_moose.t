use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Test::More;
use Data::Dumper;
use Try;
use Safe;
use Safe::Hole;

use SpaceBotWar::Game::Data;
use SpaceBotWar::Game::Ship::Mine;


my $my_ships;

my $ship = SpaceBotWar::Game::Ship::Mine->new({
    id          => 1,
    owner_id    => 1,
});
push @$my_ships, $ship;

$ship = SpaceBotWar::Game::Ship::Mine->new({
    id          => 2,
    owner_id    => 2,
});
push @$my_ships, $ship;

my $data = SpaceBotWar::Game::Data->new({
    my_ships        => $my_ships,
});

my $compartment = Safe->new;
my $hole = Safe::Hole->new({});

$hole->wrap($data, $compartment, '$data');

my $code = <<'END';
    foreach my $ship (@{$data->my_ships}) {
        $ship->thrust_forward(4);
        $ship->thrust_sideway(3);
        $data->log("Thrust Forward = [".$ship->thrust_forward."] Thrust Sideway = [".$ship->thrust_sideway."] speed=[".$ship->speed."]\n");
    }
END

$compartment->reval($code);

print $@ if $@;

is($data->my_ships->[0]->thrust_forward, 4, "Correct thrust 1");
is($data->my_ships->[1]->thrust_forward, 4, "Correct thrust 2");
is($data->my_ships->[1]->speed, 5,  "Correct thrust sideway");
diag $data->log;

done_testing();
1;



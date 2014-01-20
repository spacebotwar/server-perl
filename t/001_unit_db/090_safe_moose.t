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

my @my_ships = [
    SpaceBotWar::Game::Ship::Mine->new({
        id          => 1,
        owner_id    => 1,
    }),
    SpaceBotWar::Game::Ship::Mine->new({
        id          => 2,
        owner_id    => 2,
    });
];

our $data = SpaceBotWar::Game::Data->new({
    my_ships        => \@my_ships,
});

my $compartment = Safe->new;
my $hole = Safe::Hole->new({});

$hole->wrap($data, $compartment, '$data');

my $code = <<'END';
    $data->my_ships->[0]->thrust_forward(42);
END

$compartment->reval($code);

print $@ if $@;

diag "RETURN thrust = ".Dumper($data);

is($data->my_ships->[0]->thrust_forward, 42, "Correct thrust");


done_testing();
1;



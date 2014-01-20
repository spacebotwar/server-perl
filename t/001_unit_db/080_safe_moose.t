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

use MooseShip;

our $ship = MooseShip->new({});

my $compartment = Safe->new;
my $hole = Safe::Hole->new({});

$hole->wrap($ship, $compartment, '$ship');


$compartment->reval('$ship->thrust_forward(42);');
print $@ if $@;

diag "RETURN thrust = ".$ship->thrust_forward;

is($ship->thrust_forward, 42, "Correct thrust");


done_testing();
1;



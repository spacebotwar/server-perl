use strict;
use warnings;

use Test::More;

my $forward = 60;
my $sideway = 0;

my $delta_theta = atan2($sideway, $forward);

diag "delta_theta = $delta_theta";



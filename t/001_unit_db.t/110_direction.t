use strict;
use warnings;

use Test::More;

my $forward = 60;
my $sideway = 0;

my $delta_theta = atan2($sideway, $forward);

ok(1);
diag "delta_theta = $delta_theta";

done_testing();

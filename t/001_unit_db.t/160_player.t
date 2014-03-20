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
use SpaceBotWar::Player;


my $ship = SpaceBotWar::Player->new({
});

isa_ok($ship, 'SpaceBotWar::Player', "Correct class");


done_testing();


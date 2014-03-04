use strict;
use warnings;

use lib "../lib";
use lib "./lib";

use Test::More;
use Memory::Usage;

use SpaceBotWar::WebSocket::Player;
use MemoryLeak;

my $mu = Memory::Usage->new();
$mu->record('starting work');

foreach (1..1000) {
    my $leak = SpaceBotWar::WebSocket::Player->new;
}

$mu->record('after leak');
$mu->dump();


ok(1);
done_testing();


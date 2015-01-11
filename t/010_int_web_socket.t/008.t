use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use SpaceBotWar::Queue;
use SpaceBotWar::Redis;

use Data::Dumper;
use Test::More;
use Log::Log4perl;
use Redis;

use WSTester;

SpaceBotWar::Queue->initialize({
    server  => 'localhost:11300',
    ttr     => 120,
    debug   => 0,
});

my $redis = Redis->new(server => 'localhost:6379');
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

Log::Log4perl->init('/Users/icydee/sandbox/space-bot-war/log4perl.conf');

my $tester = WSTester->new({
    route       => "/",
    server      => 'ws://localhost:8080/ws',
});

my $client_code;
my $tests = {
    # simple test
    "000_test" => {
        method  => 'test',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'foobar',
        },
    },
};

$tester->run_tests($tests);

done_testing();


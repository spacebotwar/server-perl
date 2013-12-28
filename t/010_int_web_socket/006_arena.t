use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Test::More;
use SpaceBotWar;
use WSTester;

my $db      = SpaceBotWar->db;
my $config  = SpaceBotWar->config;

my $tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_servers/arena'),
});

my @arenas;
my $tests = {
    "000_arenas" => {
        method  => 'arenas',
        send    => {
        },
        recv    => {
            code    => 0,
            message => "Arenas",
        },
        callback => sub {
            my ($data) = @_;
            @arenas = @{$data->{content}{arenas}};
            is(scalar(@arenas), 2, "number of arenas");
        },
    },
};

$tester->run_tests($tests);

is(scalar(@arenas), 2, "number of arenas");
# Join the first room
my $arena_tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_servers/server')."/ws/match/rae",
});

my $tests2 = {
    "010_arena_status" => {
        method  => 'arena_status',
        send    => {
        },
        recv    => {
            code    => 0,
            status  => "running",
            start_time  => -35.5,
        },
    },
};

$arena_tester->run_tests($tests2);

done_testing();


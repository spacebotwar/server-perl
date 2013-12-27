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

# Testing async replies is tricky.
# All the 'tricky' bits have been factored out into the WSTester library.
#   Note that the 'client_code' and the 'msg_id' message fields are handled by WSTester
#
my $tester = WSTester->new({
    route       => "/gold/",
    server      => $config->get('ws_servers/match_gold'),
});

my $client_code;
my $tests = {
    "000_test" => {
        method  => 'test',
        send    => {
        },
        recv    => {
            code    => 0,
            message => "Success",
        },
    },
};

$tester->run_tests($tests);

done_testing();


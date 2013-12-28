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
    server      => $config->get('ws_servers/start'),
});


my $tests = {
    "000_get_client_code" => {
        method  => 'get_client_code',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
        },
    },
    "001_radius_api" => {
        method  => 'get_radius',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'radius api key',
            radius_api_key  => $config->get('radius/api_key'),
        },
    },
};

$tester->run_tests($tests);



done_testing();


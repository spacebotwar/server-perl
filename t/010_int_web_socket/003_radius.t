use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use AnyEvent::WebSocket::Client;
use JSON;
use Data::Dumper;
use Test::More;
use SpaceBotWar;
use WSTester;

my $db      = SpaceBotWar->db;
my $config  = SpaceBotWar->config;

my $tester = WSTester->new({
    route       => "/lobby/",
    server      => $config->get('ws_server'),
});


my $tests = {
    "000_get_session" => {
        method  => 'get_session',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new session',
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


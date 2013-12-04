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

my $user = $db->resultset('User')->create({
    name        => ' test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

my $tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_server'),
});

my $route = "/";
my $tests = {
    "001_login_no username"  => {
        method  => 'login_with_password',
        send    => {
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 1001,
            message     => 'username is missing',
        },
    },
};

$tester->run_tests($tests);
done_testing();


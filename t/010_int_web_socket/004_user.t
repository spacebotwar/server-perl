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

# Set up test conditions.
my $test_setup = {
    "000_get_client_code" => {
        method  => 'get_client_code',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
        },
    },
    "005_login_success"  => {
        method  => 'login_with_password',
        send    => {
            username    => 'test_user_1',
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 0,
            message     => 'Welcome',
            username    => 'test_user_1',
        },
    },
};

my $tests = {    
    "006_get_profile" => {
        method  => 'get_profile',
        send    => {},
        recv    => {
            code        => 0,
            message     => 'Success',
            profile     => {
                username    => 'test_user_1',
                email       => 'me@example.com',
            },
        },
    },
};

# Test users are those with an ID < 0
#
my $users = $db->resultset('User')->search({
    id      => { '<', 0 },
});
while (my $user = $users->next) {
    $user->delete;
}

my $user = $db->resultset('User')->create({
    id          => -1,
    name        => 'test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

$tester->route('/lobby/');
$tester->run_tests($test_setup);

$tester->route('/user/');
$tester->run_tests($tests);

done_testing();


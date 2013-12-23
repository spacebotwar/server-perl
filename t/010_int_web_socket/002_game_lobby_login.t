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
    route       => "/",
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
    "001_login_no_username"  => {
        method  => 'login_with_password',
        send    => {
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 1001,
            message     => 'username is missing',
        },
    },
    "002_login_no_password"  => {
        method  => 'login_with_password',
        send    => {
            username    => ' test_user_1',
        },
        recv    => {
            code        => 1001,
            message     => 'password is missing',
        },
    },
    "003_login_wrong_password"  => {
        method  => 'login_with_password',
        send    => {
            username    => ' test_user_1',
            password    => 'foo',
        },
        recv    => {
            code        => 1001,
            message     => 'Incorrect credentials 2',
        },
    },
    "004_login_wrong_username"  => {
        method  => 'login_with_password',
        send    => {
            username    => ' test_user_2',
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 1001,
            message     => 'Incorrect credentials 1',
        },
    },
    "005_login_success"  => {
        method  => 'login_with_password',
        send    => {
            username    => ' test_user_1',
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 0,
            message     => 'Welcome',
            username    => ' test_user_1',
        },
    },
    "007_logout"  => {
        method  => 'logout',
        send    => {
            username    => ' test_user_1',
            password    => 'Yop_s3cr3t',
        },
        recv    => {
            code        => 0,
            message     => 'Good Bye',
        },
    },
    "008_login_with_email_code_invalid" => {
        method  => 'login_with_email_code',
        send    => {
            email_code  => 'foo',
        },
        recv    => {
            code        => 1001,
            message     => 'Invalid Email Code',
        },
    },
#    "009_login_with_email_code" => {
#        method  => 'login_with_email_code',
#        send    => {
#            email_code  => 'foo',
#        },
#        recv    => {
#            code        => 0,
#            message     => 'Welcome',
#        },
#    },
};

my $users = $db->resultset('User')->search({
    name        => ' test_user_1',
});
while (my $user = $users->next) {
    $user->delete;
}


my $user = $db->resultset('User')->create({
    name        => ' test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

$tester->run_tests($tests);



done_testing();


use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use Test::More;
use SpaceBotWar;
use SpaceBotWar::EmailCode;

use WSTester;

my $db      = SpaceBotWar->db;
my $config  = SpaceBotWar->config;

my $tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_servers/start'),
});

my $invalid_email_code = SpaceBotWar::EmailCode->new({
    timeout_sec => 1,
    user_id     => 1,
})->store;

diag("INVALID: email code is [".$invalid_email_code->id."]");

# allow for the timeout of the invalid code (we could do this better)
sleep(1);

my $valid_email_code = SpaceBotWar::EmailCode->new({
    timeout_sec => 100,
    user_id     => 1,
})->store;
diag("VALID: email code is [".$valid_email_code->id."]");

isnt($invalid_email_code->id, $valid_email_code->id, 'Codes are different');

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
            email_code  => $invalid_email_code->id,
        },
        recv    => {
            code        => 1000,
            message     => 'Error',
        },
    },

    "009_login_with_email_code_valid" => {
        method  => 'login_with_email_code',
        send    => {
            email_code  => $valid_email_code->id,
        },
        recv    => {
            code        => 0,
            message     => 'Welcome',
        },
    },

    "010_forgotten_password_username" => {
        method  => 'forgot_password',
        send    => {
            username_or_email   => ' test_user_1',
        },
        recv    => {
            code        => 0,
            message     => 'Success'
        },
    },

#    "011_login_with_email_code" => {
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
    username    => ' test_user_1',
});
while (my $user = $users->next) {
    $user->delete;
}


my $user = $db->resultset('User')->create({
    username    => ' test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

$tester->run_tests($tests);



done_testing();

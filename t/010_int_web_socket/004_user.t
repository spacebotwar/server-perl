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
my $client_code = "illegal client code";
my $new_client_code;

my $tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_servers/start'),
});

# Set up test conditions.
my $test_setup = {
    "000_get_client_code" => {
        method  => 'get_client_code',
        send    => {
            client_code => $client_code,
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
        },
        callback => sub {
            my ($data) = @_;
            $new_client_code = $data->{content}{client_code};
            isnt($client_code, $new_client_code, "Got a new client code");
            $client_code = $new_client_code;
        },
    },
    "001_get_same_client_code" => {
        method  => 'get_client_code',
        send    => {
            client_code => '6ab031da-1dc9-4d87-9e1a-566e14656c9c-d0740c',
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
            client_code => '6ab031da-1dc9-4d87-9e1a-566e14656c9c-d0740c',
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
    username    => 'test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

$tester->route('/');
$tester->run_tests($test_setup);

$tester->route('/user/');
$tester->run_tests($tests);

done_testing();


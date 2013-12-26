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
    route       => "/lobby/",
    server      => $config->get('ws_server'),
});

my $client_code;
my $tests = {
    # Get a new client_code (to be used in subsequent calls)
    "000_get_client_code" => {
        method  => 'get_client_code',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
        },
        callback => sub {
            my ($data) = @_;
            diag "CALLBACK: ". Dumper($data);
            $client_code = $data->{content}{client_code};
            print STDERR "CLIENT_CODE : [$client_code]\n";
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
};

$tester->run_tests($tests);

print STDERR "CLIENT_CODE external : [$client_code]\n";

my $tester2 = WSTester->new({
    route       => "/test/",
    server      => $config->get('ws_game_server'),
});

my $tests2 = {
    # Get a new client_code (to be used in subsequent calls)
    "000_test"  => {
        method  => 'test',
        send    => {
            client_code     => $client_code,
        },
        recv    => {
            code            => 0,
            message         => 'Success',
            test_client_code    => $client_code,
        },
    },
};

$tester2->run_tests($tests2);







done_testing();


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

# Testing async replies is tricky.
# All the 'tricky' bits have been factored out into the WSTester library.
#   Note that the 'session' and the 'msg_id' message fields are handled by WSTester
#
my $tester = WSTester->new({
    route       => "/lobby/",
    server      => $config->get('ws_server'),
});

my $session;
my $tests = {
    # Get a new session (to be used in subsequent calls)
    "000_get_session" => {
        method  => 'get_session',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new session',
        },
        callback => sub {
            my ($data) = @_;
            diag "CALLBACK: ". Dumper($data);
            $session = $data->{content}{session};
            print STDERR "SESSION : [$session]\n";
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

print STDERR "SESSION external : [$session]\n";

my $tester2 = WSTester->new({
    route       => "/test/",
    server      => $config->get('ws_game_server'),
});

my $tests2 = {
    # Get a new session (to be used in subsequent calls)
    "000_test"  => {
        method  => 'test',
        send    => {
            session     => $session,
        },
        recv    => {
            code            => 0,
            message         => 'Success',
            test_session    => $session,
        },
    },
};

$tester2->run_tests($tests2);







done_testing();


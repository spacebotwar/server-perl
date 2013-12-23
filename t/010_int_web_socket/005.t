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

my $tests = {
    # Get a new session (to be used in subsequent calls)
    "000_no_session"  => {
        method  => 'register',
        send    => {
            username    => 'james_bond',
            password    => 'tops3Cr3t',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Session is missing',
        },
    },
};

$tester->run_tests($tests);
done_testing();


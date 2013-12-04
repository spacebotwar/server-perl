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

# Test the connection to the game lobby
# Testing ASYNC replies is tricky.
#   We want to be able to ensure all the requested messages have been received
#   We might not be able to guarantee the order they are received
#   We dont want to wait forever for a message that may not arrive.
#
my $tester = WSTester->new({
    route       => "/",
    server      => $config->get('ws_server'),
});

my $session;
my $route = "/";
my $tests = {
    "000_get_session" => {
        method  => 'get_session',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new session',
        },
        callback    => sub {
            my ($msg) = @_;
            $session = $msg->{content}{session};
            diag("SESSION : $session");
        },
    },
    "001_no_email"  => {
        method  => 'register',
        send    => {
            username    => 'james_bond',
            password    => 'tops3Cr3t',
        },
        recv    => {
            code        => 1001,
            message     => 'Email is missing',
        },
    },
    "002_bad_email"  => {
        method  => 'register',
        send    => {
            username    => 'james_bond',
            password    => 'tops3Cr3t',
            email       => 'foo',
        },
        recv    => {
            code        => 1001,
            message     => 'Email is invalid',
        },
    },
    "003_no_username"  => {
        method  => 'register',
        send    => {
            password    => 'tops3Cr3t',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Username must be at least 3 characters long',
        },
    },
    "005_username_taken"  => {
        method  => 'register',
        send    => {
            password    => 'tops3Cr3t',
            username    => 'icydee',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Username not available',
        },
    },
    "006_password_length"  => {
        method  => 'register',
        send    => {
            password    => 'hi',
            username    => 'james_bond',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Password must be at least 5 characters long',
        },
    },
    "006_password_number"  => {
        method  => 'register',
        send    => {
            password    => 'topSeCreT',
            username    => 'james_bond',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Password must contain numbers, lowercase and uppercase',
        },
    },
    "007_password_lower"  => {
        method  => 'register',
        send    => {
            password    => 'TOPSECRET3',
            username    => 'james_bond',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Password must contain numbers, lowercase and uppercase',
        },
    },
    "008_password_upper"  => {
        method  => 'register',
        send    => {
            password    => 'tops3cr3t',
            username    => 'james_bond',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Password must contain numbers, lowercase and uppercase',
        },
    },

    "009_all_correct"  => {
        method  => 'register',
        send    => {
            password    => 'Tops3cr3T',
            username    => 'james_bond',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 0,
            message     => 'Available',
        },
        callback    => sub {
            my ($user) = $db->resultset('User')->search({
                name    => 'james_bond',
            });
            $user->delete;
        },
    },
};

$tester->run_tests($tests);
done_testing();


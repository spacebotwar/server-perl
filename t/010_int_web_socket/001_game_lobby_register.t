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

my $tests = {
    # Get a new client_code (to be used in subsequent calls)
    "000_no_client_code"  => {
        method  => 'register',
        send    => {
            username    => 'james_bond',
            password    => 'tops3Cr3t',
            email       => 'jb@mi6.gov.org.uk',
        },
        recv    => {
            code        => 1001,
            message     => 'Client Code is missing',
        },
    },
    "001_get_client_code" => {
        method  => 'get_client_code',
        send    => {
        },
        recv    => {
            code        => 0,
            message     => 'new Client Code',
        },
    },
    # After this point the WSTester will inject the client_code
     "002_no_email"  => {
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
    "003_bad_email"  => {
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
    "004_no_username"  => {
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
    "007_password_number"  => {
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
    "008_password_lower"  => {
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
    "009_password_upper"  => {
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

    "010_all_correct"  => {
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


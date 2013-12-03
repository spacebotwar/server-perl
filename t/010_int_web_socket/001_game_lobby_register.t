use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use AnyEvent::WebSocket::Client;
use JSON;
use Data::Dumper;
use Test::More;
use SpaceBotWar;


my $cv = AnyEvent->condvar;
my $db = SpaceBotWar->db;
my $connection;

# Test the connection to the game lobby
# Testing ASYNC replies is tricky.
#   We want to be able to ensure all the requested messages have been received
#   We might not be able to guarantee the order they are received
#   We dont want to wait forever for a message that may not arrive.
#

my $route = "/";
my $tests = {
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



# Not ideal to make a connection for each test, but it's the easiest way
# I have found so far!
#
for my $key (sort keys %$tests) {
    my $test = $tests->{$key};

    my $cv = AnyEvent->condvar;
    #diag("test $key");
    my $client = AnyEvent::WebSocket::Client->new;
    $client->connect("ws://git.icydee.com:5000/ws/game/lobby")->cb(sub {

        $connection = eval { shift->recv };
        if ($@) {
            BAIL_OUT("Cannot connect to server");
        }

        $connection->on(finish => sub {
            my ($connection) = @_;
            fail("FINISH signal received");
        #    $cv->send;
        });

        # We need to time-out if the connection fails to respond correctly.
        my $test_timer = AnyEvent->timer(
            after   => 1,
            cb      => sub {
                $cv->send;
                fail("Timer expired");
            },
        );


        my $content = $test->{send};
        $content->{id} = $key;

        send_json($connection, {
            route   => $route.$test->{method},
            content => $content,
        });

        # We should get one reply for each message

        $connection->on(each_message => sub {
            my ($connection, $message) = @_;

            my $json = JSON->new->decode($message->body);
            my $content = $json->{content};
            #diag "RECEIVED: ".Dumper($json);
            my $method = $json->{route};
            $method =~ s{^/}{};

            if ($method eq 'lobby_status') {
                # We can ignore these
            }
            elsif ($method ne $test->{method}) {
#                fail("Unexpected method '$method'");
            }
            else {
                my $id = $content->{id} || '';
                if ($id eq $key) {
                    for my $r_key (%{$test->{recv}}) {
                        is($content->{$r_key}, $test->{recv}{$r_key}, "$id - $r_key - is correct");
                    }
                }
                else {
                    fail("Unexpected id '$id'");
                }
                $cv->send;
                undef $test_timer; # cancel the timer
            }
        });
    });
    # Go into loop waiting for all responses
    $cv->recv;

    # Do any tidyup (if needed)
    my $cb = $test->{callback};
    if ($cb) {
        &$cb();
    }
}




sub send_json {
    my ($connection, $json) = @_;

    my $msg = JSON->new->encode($json);
    #diag("send_json: $msg");

    $connection->send($msg);
}


done_testing();




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

my $client = AnyEvent::WebSocket::Client->new;

my $cv = AnyEvent->condvar;
my $connection;

# Set up test account
# (with a name with a leading space, something that would not normally be possible
# since 'register' prevents it.
#
my $db = SpaceBotWar->db;

my $user = $db->resultset('User')->create({
    name        => ' test_user_1',
    password    => 'Yop_s3cr3t',
    email       => 'me@example.com',
});

$client->connect("ws://localhost:5000/ws/game/lobby")->cb(sub {
    $connection = eval { shift->recv };
    if ($@) {
        BAIL_OUT("Cannot connect to server");
    }

    send_json($connection, {
        route   => '/login_with_password',
        content => {
            id          => 'test_user_1',
            username    => ' test_user_1',
            password    => 'Yop_s3cr3t',
        }
    });

    # Test each message that is received
    #
    $connection->on(each_message => sub {
        my ($connection, $message) = @_;

        test_message($message);
    });

    # Handle a finish from the server
    #
    $connection->on(finish => sub {
        my ($connection) = @_;
        fail("FINISH: received");
    });
});

# How many of each message type do we expect to see?
my $received_messages = {
    lobby                   => 1,
    login_with_password     => 1,
};

# What test IDs should we see.
my $test_ids = {
    test_user_1             => 0,
};

# We need to time-out if the connection fails to respond correctly.
my $test_timer = AnyEvent->timer(
    after   => 2, # seconds
    cb      => sub {
        $cv->send;
    },
);


# Encode and sent the message
#
sub send_json {
    my ($connection, $json) = @_;

    my $msg = JSON->new->encode($json);

    $connection->send($msg);
}

sub test_message {
    my ($message) = @_;

    my $json = JSON->new->decode($message->body);
    my $content = $json->{content};

    my $method = $json->{route};
    $method =~ s{^/}{};

    if (not exists $received_messages->{$method}) {
        # unexpected method
        fail("Unexpected method '$method'");
    }

    my $id = $content->{id} || '';
    if ($id eq 'test_user_1') {
        ok('test_user_1 received');
    }

    if ($id eq 'reg_1_valid') {
        is($json->{content}{code},      0,                          'reg_1_valid    - Code is correct');
        is($json->{content}{message},   'Available',                'reg_1_valid    - Message is correct');
        is($json->{content}{data},      'james_bond',               'reg_1_valid    - Data is correct');
        is($method,                     'register',                 'reg_1_valid    - Method is correct');
    }

    $received_messages->{$method}--;

    my $tests_run = grep {$received_messages->{$_} <= 0} keys %$received_messages;

    if ($tests_run == keys %$received_messages) {
        # then terminate the tests
        $cv->send;
    }
}

$cv->recv;

# See if all the expected messages have been received.
#
foreach my $key (keys %$received_messages) {
    is($received_messages->{$key}, 0, "message: $key");
}

done_testing();



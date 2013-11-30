
use strict;
use warnings;

use AnyEvent::WebSocket::Client;
use JSON;
use Data::Dumper;
use Test::More;

my $client = AnyEvent::WebSocket::Client->new;

my $cv = AnyEvent->condvar;
my $connection;

# Test the connection to the game lobby
# Testing ASYNC replies is tricky.
#   We want to be able to ensure all the requested messages have been received
#   We might not be able to guarantee the order they are received
#   We don't want to wait forever for a message that may not arrive.
#

# How many of each message type do we expect to see?
my $received_messages = {
    lobby_status    => 1,
    register_status => 5,
};

# What test IDs should we see.
my $test_ids = {
    reg_1_valid             => 0,
    reg_2_no_email          => 0,
    reg_3_no_username       => 0,
    reg_4_username_taken    => 0,
    reg_5_password_error    => 0,
};

# We need to time-out if the connection fails to respond correctly.
my $test_timer = AnyEvent->timer(
    after   => 2,
    cb      => sub {
        $cv->send;
    },
);

sub test_message {
    my ($message) = @_;

    my $json = JSON->new->decode($message->body);
    my $content = $json->{content};
#    diag Dumper($json);

    my $method = $json->{route};
    $method =~ s{^/}{};

    if (not exists $received_messages->{$method}) {
        # unexpected method
        fail("Unexpected method '$method'");
    }

    if ($method eq 'lobby_status') {
        
    }

    my $id = $content->{id};
    if ($id and $id eq 'reg_1_valid') {
        is($json->{content}{code},      0,                          'reg_1_valid    - Code is correct');
        is($json->{content}{status},    'ok',                       'reg_1_valid    - status is correct');
        is($json->{content}{message},   'Welcome back!',            'reg_1_valid    - Message is correct');
        is($method,                     'register_status',          'reg_1_valid    - Method is correct');
    }

    if ($id and $id eq 'reg_2_no_email') {
        is($json->{content}{code},      1001,                       'reg_2_no_email - Code is correct');
        is($json->{content}{status},    'failure',                  'reg_2_no_email - status is correct');
        is($json->{content}{message},   'Missing email address',    'reg_2_no_email - Message is correct');
        is($method,                     'register_status',          'reg_2_no_email - Method is correct');
    }

    if ($id and $id eq 'reg_3_no_username') {
        is($json->{content}{code},      1002,                       'reg_3_no_username - Code is correct');
        is($json->{content}{status},    'failure',                  'reg_3_no_username - status is correct');
        is($json->{content}{message},   'Missing email username',   'reg_3_no_username - Message is correct');
        is($method,                     'register_status',          'reg_3_no_username - Method is correct');
    }

    if ($id and $id eq 'reg_4_username_taken') {
        is($json->{content}{code},      1003,                       'reg_4_username_taken - Code is correct');
        is($json->{content}{status},    'failure',                  'reg_4_username_taken - status is correct');
        is($json->{content}{message},   'Username already taken',   'reg_4_username_taken - Message is correct');
        is($method,                     'register_status',          'reg_4_username_taken - Method is correct');
    }

    if ($id and $id eq 'reg_5_password_error') {
        is($json->{content}{code},      1004,                       'reg_5_password_error - Code is correct');
        is($json->{content}{status},    'failure',                  'reg_5_password_error - status is correct');
        is($json->{content}{message},   'Password is not strong',   'reg_5_password_error - Message is correct');
        is($method,                     'register_status',          'reg_5_password_error - Method is correct');
    }

    is($json->{room}, 'lobby', 'Room is correct');

    $received_messages->{$method}--;

    my $tests_run = grep {$received_messages->{$_} <= 0} keys %$received_messages;

    if ($tests_run == keys %$received_messages) {
        # then terminate the tests
        $cv->send;
    }
}

sub send_json {
    my ($connection, $json) = @_;

    my $msg = JSON->new->encode($json);

    $connection->send($msg);
}


$client->connect("ws://localhost:5000/ws/game/lobby")->cb(sub {
    $connection = eval { shift->recv };
    if ($@) {
        BAIL_OUT("Cannot connect to server");
    }


    # reg_test_1 - everything valid
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_test_1',
            username    => 'james_bond',
            password    => 'tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_test_2 - no email address 
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_2_no_email',
            username    => 'james_bond',
            password    => 'tops3cr3t',
        }
    });

    # reg_test_3 - no username
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_3_no_username',
            password    => 'tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_test_4 - username already taken
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_4_username_taken',
            username    => 'icydee',
            password    => 'tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_test_5 - invalid password
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_5_password_error',
            username    => 'james_bond',
            password    => 'hi',
            email       => 'agent007@example.com',
        }
    });

    $connection->on(each_message => sub {
        my ($connection, $message) = @_;

        test_message($message);
    });

    $connection->on(finish => sub {
        my ($connection) = @_;
        diag "FINISH: received";
    #    $cv->send;
    });
});

$cv->recv;

# See if all the expected messages have been received.
#
foreach my $key (keys %$received_messages) {
    is($received_messages->{$key}, 0, "message: $key");
}

done_testing();



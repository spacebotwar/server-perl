
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
    lobby       => 1,
    register    => 9,
};

# What test IDs should we see.
my $test_ids = {
    reg_1_valid             => 0,
    reg_2_no_email          => 0,
    reg_3_bad_email         => 0,
    reg_4_no_username       => 0,
    reg_5_username_taken    => 0,
    reg_6_password_length   => 0,
    reg_7_password_number   => 0,
    reg_8_password_lower    => 0,
    reg_9_password_upper    => 0,
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
    #diag "RECEIVED: ".Dumper($json);

    my $method = $json->{route};
    $method =~ s{^/}{};

    if (not exists $received_messages->{$method}) {
        # unexpected method
        fail("Unexpected method '$method'");
    }

    if ($method eq 'lobby_status') {
        
    }

    my $id = $content->{id} || '';
    #diag "##### [$id] ########";
    if ($id eq 'reg_1_valid') {
        is($json->{content}{code},      0,                          'reg_1_valid    - Code is correct');
        is($json->{content}{message},   'Available',                'reg_1_valid    - Message is correct');
        is($json->{content}{data},      'james_bond',               'reg_1_valid    - Data is correct');
        is($method,                     'register',                 'reg_1_valid    - Method is correct');
    }

    if ($id eq 'reg_2_no_email') {
        is($json->{content}{code},      1001,                       'reg_2_no_email - Code is correct');
        is($json->{content}{message},   'Email is missing',         'reg_2_no_email - Message is correct');
        is($method,                     'register',                 'reg_2_no_email - Method is correct');
    }

    if ($id eq 'reg_3_bad_email') {
        is($json->{content}{code},      1001,                       'reg_3_bad_email - Code is correct');
        is($json->{content}{message},   'Email is invalid',         'reg_3_bad_email - Message is correct');
        is($method,                     'register',                 'reg_3_bad_email - Method is correct');
    }

    if ($id eq 'reg_4_no_username') {
        is($json->{content}{code},      1001,                       'reg_4_no_username - Code is correct');
        is($json->{content}{message},   'Username must be at least 3 characters long',         'reg_4_no_username - Message is correct');
        is($method,                     'register',                 'reg_4_no_username - Method is correct');
    }

    if ($id eq 'reg_5_username_taken') {
        is($json->{content}{code},      1001,                       'reg_5_username_taken - Code is correct');
        is($json->{content}{message},   'Username not available',   'reg_5_username_taken - Message is correct');
        is($method,                     'register',                 'reg_5_username_taken - Method is correct');
    }

    if ($id eq 'reg_6_password_length') {
        is($json->{content}{code},      1001,                       'reg_6_password_length - Code is correct');
        is($json->{content}{message},   'Password must be at least 5 characters long',   'reg_6_password_length - Message is correct');
        is($method,                     'register',                 'reg_6_password_length - Method is correct');
    }

    if ($id eq 'reg_7_password_number') {
        is($json->{content}{code},      1001,                       'reg_7_password_number - Code is correct');
        is($json->{content}{message},   'Password must contain numbers, lowercase and uppercase',   'reg_7_password_number - Message is correct');
        is($method,                     'register',                 'reg_7_password_number - Method is correct');
    }

    if ($id eq 'reg_8_password_lower') {
        is($json->{content}{code},      1001,                       'reg_8_password_lower - Code is correct');
        is($json->{content}{message},   'Password must contain numbers, lowercase and uppercase',   'reg_8_password_lower - Message is correct');
        is($method,                     'register',                 'reg_8_password_lower - Method is correct');
    }

    if ($id eq 'reg_9_password_upper') {
        is($json->{content}{code},      1001,                       'reg_9_password_upper - Code is correct');
        is($json->{content}{message},   'Password must contain numbers, lowercase and uppercase',   'reg_9_password_upper - Message is correct');
        is($method,                     'register',                 'reg_9_password_upper - Method is correct');
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
#    print STDERR "send_json: $msg\n";

    $connection->send($msg);
}


$client->connect("ws://localhost:5000/ws/game/lobby")->cb(sub {
    $connection = eval { shift->recv };
    if ($@) {
        BAIL_OUT("Cannot connect to server");
    }


    # reg_1_valid - everything valid
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_1_valid',
            username    => 'james_bond',
            password    => 'Tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_2_no_email - no email address 
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_2_no_email',
            username    => 'james_bond',
            password    => 'tops3cr3t',
        }
    });

    # reg_3_bad_email - invalid email address 
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_3_bad_email',
            username    => 'james_bond',
            password    => 'tops3cr3t',
            email       => 'foo',
        }
    });

    # reg_4_no_username - no username
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_4_no_username',
            password    => 'tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_5_username_taken - username already taken
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_5_username_taken',
            username    => 'icydee',
            password    => 'tops3cr3t',
            email       => 'agent007@example.com',
        }
    });

    # reg_6_password_error - invalid password
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_6_password_length',
            username    => 'james_bond',
            password    => 'hi',
            email       => 'agent007@example.com',
        }
    });

    # reg_7_password_number - invalid password
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_7_password_number',
            username    => 'james_bond',
            password    => 'hiHIhiHI',
            email       => 'agent007@example.com',
        }
    });

    # reg_8_password_lower - invalid password
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_8_password_lower',
            username    => 'james_bond',
            password    => 'HI343HHT3',
            email       => 'agent007@example.com',
        }
    });

    # reg_9_password_higher - invalid password
    send_json($connection, {
        route   => '/register',
        content => {
            id          => 'reg_9_password_higher',
            username    => 'james_bond',
            password    => 'lower3th3',
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



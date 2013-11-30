
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

my $received_messages = {
    lobby_status    => 0,
    register_status => 0,
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

    my $method = $json->{route};
    $method =~ s{^/}{};
    $received_messages->{$method} = 1;

    # If all the messages have been received, we can terminate the test.
    # if (tests_done) { $cv->send; }

}

$client->connect("ws://localhost:5000/ws/game/lobby")->cb(sub {
    $connection = eval { shift->recv };
    if ($@) {
        BAIL_OUT("Cannot connect to server");
    }

    $connection->send('{ "route" : "/register", "content" : { "username" : "james_bond", "password" : "tops3cr3t", "email" : "agent007@mi6.gov.org.uk" } }');

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
    is($received_messages->{$key}, 1, "message: $key");
}

done_testing();



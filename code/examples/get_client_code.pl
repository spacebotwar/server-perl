#! /usr/local/bin/perl
# Demonstrate the minimum code to get the client code

use AnyEvent::WebSocket::Client;
use Data::Dumper;
use JSON;

my $client = AnyEvent::WebSocket::Client->new;
my $cv = AnyEvent->condvar;
$client->connect("ws://spacebotwar.com:5000/ws/user")->cb(sub {

    our $connection = eval { shift->recv };
    if ($@) {
        print STDERR "Connection failed!\n";
        return;
    }
    print STDERR "Connection made\n";
    my $client_message = {
        route   => '/client_code',
        content => {
            msg_id  => 123,
            client_code => 'bad',
        },
    };
    my $json = JSON->new;
    $connection->send($json->encode($client_message));

    $connection->on( each_message => sub {
        my ($connection, $message) = @_;

        my $json_msg = eval {$json->decode($message->body)};
        if ($@) {
            print STDERR "Fatal error [$@]\n";
            return;
        }
        print STDERR "Message: [".Dumper($json_msg)."]\n";
        if ($json_msg->{content}{msg_id} == 123) {
            $cv->send;
        }
    });

});

$cv->recv;


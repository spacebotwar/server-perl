
use strict;
use warnings;

use AnyEvent::WebSocket::Client;

my $client = AnyEvent::WebSocket::Client->new;

my $cv = AnyEvent->condvar;
my $connection;

$client->connect("ws://spacebotwar.com:5000/ws/user/register")->cb(sub {
    $connection = eval { shift->recv };
    if ($@) {
        print STDERR "Cannot connect\n";
        die;
    }
    print STDERR "CONNECTED!\n";

    $connection->send('{ "route" : "user", "method" : "register", "content" : { "foo" : "bar" } }');

    $connection->on(each_message => sub {
        my ($connection, $message) = @_;

        print STDERR "received: ".$message->body."\n";
        $connection->close;
    });

    $connection->on(finish => sub {
        my ($connection) = @_;

        print STDERR "FINISH\n";
        $cv->send;
    });
});

print STDERR "GOT HERE\n";
$cv->recv;



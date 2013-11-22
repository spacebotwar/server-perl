use AnyEvent::WebSocket::Client;

my $client = AnyEvent::WebSocket::Client->new;

{
$client->connect("ws://spacebotwar.com:3000/ws")->cb(sub {
    my $connection = eval { shift->recv };
    if ($@) {
        die "Got an error $@";
    }

    $connection->send('{"type" : "room", "content" : { "number" : 5 } }');

    $connection->on(each_message => sub {
        my ($connection, $message) = @_;

        print STDERR $message."\n";
    });
});



sleep 30;
}


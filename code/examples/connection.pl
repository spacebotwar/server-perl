#! /usr/local/bin/perl

use AnyEvent::WebSocket::Client;

my $client = AnyEvent::WebSocket::Client->new;
my $cv = AnyEvent->condvar;
$client->connect("ws://spacebotwar.com:5000/ws/start")->cb(sub {
    print STDERR "Connection made\n";
    $cv->send;
});

$cv->recv;


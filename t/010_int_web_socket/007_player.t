
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



        my $server = "ws://spacebotwar.co.uk:5001/ws/player/darwin";
        my $content = {
        };
        my $key = 123;
        my $route = "/next_move";

        my $cv = AnyEvent->condvar;
        # We need to time-out if the connection fails to respond correctly.
        my $test_timer = AnyEvent->timer(
            after   => 20,
            cb      => sub {
                $cv->send;
                fail("Timer expired");
            },
        );

        my $client = AnyEvent::WebSocket::Client->new;
        my $connection;
        my $json;
        
        $client->connect($server)->cb(sub {

            $connection = eval { shift->recv };
            if ($@) {
                BAIL_OUT("Cannot connect to server [".$server."]");
            }

            $connection->on(finish => sub {
                my ($connection) = @_;
                fail("FINISH signal received");
            });

            $content->{msg_id} = $key;

            my $msg = JSON->new->encode({
                route   => $route,
                content => $content,
            });
            diag("SEND: $msg");
            $connection->send($msg);

            # We should get one reply for each message

            $connection->on(each_message => sub {
                my ($connection, $message) = @_;
    
                $json = JSON->new->decode($message->body);
                my $content = $json->{content};
                diag "RECEIVED: ".Dumper($json);
                my ($method) = $json->{route} =~ m{/([^/]*)$};;

            my $msg = JSON->new->encode({
                route   => $route,
                content => $content,
            });
            diag("SEND: $msg");
            $connection->send($msg);


            });
        });
        # Go into event loop waiting for all responses
        $cv->recv;
        $connection->close;
        #diag("EXIT");

package WSTester;

use Moose;
use namespace::autoclean;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use AnyEvent::WebSocket::Client;
use JSON;
use Data::Dumper;
use Test::More;
use SpaceBotWar;


has 'route' => (
    is      => 'rw',
    isa     => 'Str',
    default => '/',
);

has 'server' => (
    is      => 'rw',
    isa     => 'Str',
    required    => 1,
);

sub run_tests {
    my ($self, $tests) = @_;

    # Not ideal to make a connection for each test, but it's the easiest way
    # I have found so far!
    #
    my $session;
    for my $key (sort keys %$tests) {
        my $test = $tests->{$key};
    
        my $cv = AnyEvent->condvar;
        #diag("test $key");
        # We need to time-out if the connection fails to respond correctly.
        my $test_timer = AnyEvent->timer(
            after   => 0.3,
            cb      => sub {
                $cv->send;
                fail("Timer expired");
            },
        );

        my $client = AnyEvent::WebSocket::Client->new;
        my $connection;
        my $json;
        
        $client->connect($self->server)->cb(sub {

            $connection = eval { shift->recv };
            if ($@) {
                BAIL_OUT("Cannot connect to server");
            }

            $connection->on(finish => sub {
                my ($connection) = @_;
                fail("FINISH signal received");
            #    $cv->send;
            });

            my $content = $test->{send};
            if (defined $session) {
                $content->{session} = $session;
            }
            $content->{id} = $key;

            my $msg = JSON->new->encode({
                route   => $self->route.$test->{method},
                content => $content,
            });
            #diag("SEND: $msg");
            $connection->send($msg);

            # We should get one reply for each message

            $connection->on(each_message => sub {
                my ($connection, $message) = @_;
    
                $json = JSON->new->decode($message->body);
                my $content = $json->{content};
                #diag "RECEIVED: ".Dumper($json);
                my $method = $json->{route};
                $method =~ s{^/}{};
                if (defined $content->{session}) {
                    $session = $content->{session};
                }
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
        # Go into event loop waiting for all responses
        #diag("GOT HERE!");
        $cv->recv;

        # Do any tidyup (if needed)
        my $cb = $test->{callback};
        if ($cb) {
            &$cb($json);
        }
    }
    #$cv->recv;
}


__PACKAGE__->meta->make_immutable;


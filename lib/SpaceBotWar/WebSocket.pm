package SpaceBotWar::WebSocket;

use strict;
use warnings;

use parent qw(Plack::Component);
use Carp;
use Plack::Response;
use AnyEvent::WebSocket::Server;
use Try::Tiny;
use Plack::App::WebSocket::Connection;
use JSON;
use Data::Dumper;

# It's not ideal to load everything here, but it will do for now.
# Perhaps we need to use 'pluggable'?
#
use SpaceBotWar::WebSocket::Game::User;
use SpaceBotWar::WebSocket::Context;



my $ERROR_ENV = "plack.app.websocket.error";

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self->{websocket_server} = AnyEvent::WebSocket::Server->new();
    return $self;
}

sub on_error {
    my ($self, $env) = @_;

    my $res = Plack::Response->new;
    $res->content_type("text/plain");
    if (!defined($env->{$ERROR_ENV})) {
        $res->status(500);
        $res->body("Unknown error");
    }
    elsif ($env->{$ERROR_ENV} eq "not supported by the PSGI server") {
        $res->status(500);
        $res->body("The server does not support WebSocket.");
    }
    elsif ($env->{$ERROR_ENV} eq "invalid request") {
        $res->status(400);
        $res->body("The request is invalid for a WebSocket request.");
    }
    else {
        $res->status(500);
        $res->body("Unknown error: $env->{$ERROR_ENV}");
    }
    $res->content_length(length($res->body));
    return $res->finalize;
}

sub _respond_via {
    my ($responder, $psgi_res) = @_;
    if (ref($psgi_res) eq "CODE") {
        $psgi_res->($responder);
    }
    else {
        $responder->($psgi_res);
    }
}


sub fatal {
    my ($connection, $msg) = @_;

    print STDERR $msg;
    $connection->send(qw( { "ERROR" : "$@" } ) );
}

sub render_json {
    my ($self, $context, $json) = @_;

    my $sent = JSON->new->encode($json);
    print STDERR "SEND: [$sent]\n";

    $context->connection->send($sent);
}


# Establish a connection
sub on_establish {
    my ($self, $connection, $env) = @_;

    my $room = $self->{room};
    
    $self->on_connect($room, $connection);

    $connection->on(
        message => sub {
            my ($connection, $msg) = @_;

            print STDERR "RCVD: $msg\n";
            my $json = JSON->new;
            my $json_msg = eval {$json->decode($msg)};
            if ($@) {
                print STDERR "ERROR: $@\n";
                $self->fatal($connection, $@);
            }
            else {
                my $path    = $json_msg->{route};
                my $content = $json_msg->{content} || {};
                my $id      = $content->{id};
                my ($route, $method) = $path =~ m{(.*)/([^/]*)};
                $method = "ws_".$method;
                $route =~ s{/}{::};
                $route =~ s/([\w']+)/\u\L$1/g;      # Capitalize user::foo to User::Foo
                if ($route) {
                    $route = ref($self)."::".$route;
                }
                else {
                    $route = ref($self);
                }
                my $obj = $route->new({});
                my $context = SpaceBotWar::WebSocket::Context->new({
                    room            => $room,
                    connection      => $connection,
                    content         => $content,
                });

                eval {
                    my $reply = $obj->$method($context);
                    if ($reply) {
                        # Send back the message ID
                        if ($content->{id}) {
                            $reply->{content}{id} = $content->{id}
                        }
                        $self->render_json($context, $reply);
                    }
                };

                my @error;
                if ($@ and ref($@) eq 'ARRAY') {
                    @error = @{$@};
                }
                elsif ($@) {
                    @error = (
                        1000,
                        'unknown error',
                        $@,
                    );
                }
                if (@error) {
                    my $msg = {
                        route   => $path,
                        room    => $room,
                        content => {
                            code        => $error[0],
                            message     => $error[1],
                            data        => $error[2],
                            id          => $id,
                        },
                    };
                    $msg = JSON->new->encode($msg);
                    print STDERR "SEND: $msg\n";
                    $connection->send($msg);
                }
            }
       }
   );
   $connection->on(
       finish => sub {
           undef $connection;
           warn "Bye!!\n";
       },
   );
}

sub call {
    my ($self, $env) = @_;

    if (!$env->{"psgi.streaming"} || !$env->{"psgi.nonblocking"} || !$env->{"psgix.io"}) {
        $env->{$ERROR_ENV} = "not supported by the PSGI server";
        return $self->on_error($env);
    }
    my $cv_conn = $self->{websocket_server}->establish_psgi($env, $env->{"psgix.io"});
    return sub {
        my $responder = shift;
        $cv_conn->cb(sub {
            my ($cv_conn) = @_;
            my ($conn) = try { $cv_conn->recv };
            if (!$conn) {
                $env->{$ERROR_ENV} = "invalid request";
                _respond_via($responder, $self->on_error($env));
                return;
            }
            $self->on_establish(Plack::App::WebSocket::Connection->new($conn, $responder), $env);
        });
    };
}

1;

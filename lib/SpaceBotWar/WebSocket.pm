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

#sub send_status {
#    my ($connection, $status, $code, $message) = @_;
#
#    my $msg = {
#        route       => '/lobby_status',
#        room        => 'goo',
#        content     => {
#            status      => $status,
#            code        => $code,
#            message     => $message,
#        },
#    };
#    $connection->send(JSON->new->encode($msg));
#}

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
                print STDERR "GOT HERE [$route][$method]\n";
                my $obj = $route->new({});
                eval {
                    # We may change this to pass in a '$content' object if it requires
                    # more than a couple of parameters.
                    $obj->$method($room, $connection, $content);
                };
                if ($@) {
                    print STDERR "METHOD ERROR: $@\n";
                }

                print STDERR "got here route[$route] method [$method] obj[$obj]\n";
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

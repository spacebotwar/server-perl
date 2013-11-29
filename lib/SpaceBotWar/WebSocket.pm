package SpaceBotWar::WebSocket;

use strict;
use warnings;

use parent qw(Plack::Component);
use Carp;
use Plack::Response;
use AnyEvent::WebSocket::Server;
use Try::Tiny;
use Plack::App::WebSocket::Connection;
use JSON qw(decode_json);
use Data::Dumper;

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

# Establish a connection
sub on_establish {
    my ($self, $connection, $env) = @_;

    # env->{PATH_INFO} = '/user/foo/register';
    # Convert this to 'User::Foo'
    #

    $connection->on(
        message => sub {
            my $json = JSON->new;
            my ($connection, $msg) = @_;
            print STDERR "RCVD: $msg\n";
            my $json_msg = eval {$json->decode($msg)};
            if ($@) {
                print STDERR "ERROR: $@\n";
                $connection->send(' { "error" : '.$@.' } ');
            }
            else {
                print STDERR "got here!\n";
                my $send = {
                    route   => 'route goes here',
                    self    => "$self",
                    method  => 'method goes here',
                    content => { foo => 'bar-boom' },
                };
                print STDERR "got here 2!\n";
                my $sent = $json->encode($send);
                print STDERR "SEND: $sent\n";
                $connection->send($sent);
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

    #print STDERR "DUMPER: ".Dumper(\$env);
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

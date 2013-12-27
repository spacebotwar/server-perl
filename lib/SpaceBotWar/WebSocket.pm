package SpaceBotWar::WebSocket;

use strict;
use warnings;

use parent qw(Plack::Component);
use Carp;
use Plack::Response;
use AnyEvent;
use AnyEvent::WebSocket::Server;
use Try::Tiny;
use Plack::App::WebSocket::Connection;
use JSON;
use Data::Dumper;

# It's not ideal to load everything here, but it will do for now.
# Perhaps we need to use 'pluggable'?
#
#use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::WebSocket::Context;


sub BUILD {
    my ($self) = @_;

    # every half second, send a status message (for test purposes)
    #
    print STDERR "BUILD: SpaceBotWar::WebSocket $self\n";
    AnyEvent->timer (
        after       => 0.1,
        interval    => 0.5,
        cb          => sub {
            #print STDERR "PING: $self\n";
        },
    );
}

sub DEMOLISH {
    my ($self) = @_;

    print STDERR "DEMOLISH: SpaceBotWar::WebSocket $self\n";
}

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

sub on_connect {
    my ($self, $context) = @_;

    return {};
}

# Establish a connection
sub on_establish {
    my ($self, $connection, $env) = @_;

#print STDERR "ON EST: $self\n";

    my $room = $self->{room};
    
    my $context = SpaceBotWar::WebSocket::Context->new({
        room            => $room,
        connection      => $connection,
        content         => {},
    });
#print STDERR "ON EST: 2\n";
    my $reply = {
        room    => $room,
        route   => '/',
        content => $self->on_connect($context),
    };
#print STDERR "ON EST: 3\n";
    if ($reply) {
        $self->render_json($context, $reply);
    }
    # Not sure about this. it is the DB user object
    # should we be retaining this in memory like this?
    # Should the web socket care?
    my $user;
    my $client_code;
#print STDERR "ON EST: 4\n";
    
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
#print STDERR "GOT HERE!\n";
                my $path    = $json_msg->{route};
                my $content = $json_msg->{content} || {};
                if (defined $content->{client_code}) {
                    if (not defined $client_code or $content->{client_code} ne $client_code->id) {
                        $client_code = SpaceBotWar::ClientCode->validate_client_code($content->{client_code});
                    }
                }
                if (defined $client_code and defined $client_code->user_id) {
                    if (not defined $user or $client_code->user_id != $user->id) {
                        $user = SpaceBotWar->db->resultset('User')->find($client_code->user_id);
                    }
                }

                my $msg_id  = $content->{msg_id};
                eval {
                    my ($route, $method) = $path =~ m{(.*)/([^/]*)};
                    $method = "ws_".$method;
#print STDERR "ROUTE 1[$route]\n";
                    $route =~ s{/$}{};
                    $route =~ s{^/}{};
#print STDERR "ROUTE 2[$route]\n";
                    $route =~ s{/}{::};
#print STDERR "ROUTE 3[$route]\n";
                    $route =~ s/([\w']+)/\u\L$1/g;      # Capitalize user::foo to User::Foo
#print STDERR "ROUTE 4[$route] self=[$self]\n";
                    if ($route) {
                        $route = ref($self)."::".$route;
                    }
                    else {
                        $route = ref($self);
                    }
#print STDERR "ROUTE 5[$route]\n";
                    eval "require $route";
                    my $obj = $route->new({});
                    my $context = SpaceBotWar::WebSocket::Context->new({
                        room            => $room,
                        connection      => $connection,
                        content         => $content,
                        client_code         => $client_code,
                        user            => $user,
                    });
#print STDERR "ROUTE [$obj][$method]\n";
                    my $reply = $obj->$method($context);
                    if ($reply) {
                        # Send back the message ID
                        if ($content->{msg_id}) {
                            $reply->{msg_id} = $content->{msg_id}
                        }
                        $reply = {
                            room    => $room,
                            route   => $path,
                            content => $reply,
                        };

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
                            msg_id      => $msg_id,
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

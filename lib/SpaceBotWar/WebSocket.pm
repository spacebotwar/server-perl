package SpaceBotWar::WebSocket;

use Moose;
use MooseX::NonMoose;

extends 'Plack::Component';
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
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::WebSocket::Context;


has websocket_server  => (
    is        => 'ro',
    default => sub {
        return AnyEvent::WebSocket::Server->new();
    },
);

has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
);


sub BUILD {
    my ($self) = @_;

    # every half second, send a status message (for test purposes)
    #
    $self->log->debug("Built");
}

sub DEMOLISH {
    my ($self) = @_;
    $self->log->debug("Demolished");
}

my $ERROR_ENV = "plack.app.websocket.error";

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
    my ($self, $connection, $msg) = @_;

    $self->log->error($@);
}

sub render_json {
    my ($self, $context, $json) = @_;

    my $sent = JSON->new->encode($json);
    $self->log->info("Sent: [$sent]");
    $context->connection->send($sent);
}

sub on_connect {
    my ($self, $context) = @_;

    return {};
}

# Establish a connection
sub on_establish {
    my ($self, $connection, $env) = @_;

    $self->log->debug("Establish");

    my $room = $self->{room};
    
    my $context = SpaceBotWar::WebSocket::Context->new({
        room            => $room,
        connection      => $connection,
        content         => {},
    });
    $self->log->debug("Establish");
    my $reply = {
        room    => $room,
        route   => '/',
        content => $self->on_connect($context),
    };
    $self->log->debug("Establish");
    if ($reply) {
        $self->render_json($context, $reply);
    }
    # Not sure about this. it is the DB user object
    # should we be retaining this in memory like this?
    # Should the web socket care?
    my $user;
    my $client_code;
    $self->log->debug("Establish");
    
    $connection->on(
        message => sub {
            my ($connection, $msg) = @_;

            $self->log->info("RCVD: $msg");

            my $json = JSON->new;
            my $json_msg = eval {$json->decode($msg)};
            if ($@) {
                $self->log->error($@);
                $self->fatal($connection, $@);
                return;
            }

            $self->log->debug("Establish");
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
                $route =~ s{/$}{};
                $route =~ s{^/}{};
                $route =~ s{/}{::};
                $route =~ s/([\w']+)/\u\L$1/g;      # Capitalize user::foo to User::Foo
                $self->log->debug("route = [$route]");
                if ($route) {
                    $route = ref($self)."::".$route;
                }
                else {
                    $route = ref($self);
                }
                $self->log->debug("route = [$route]");
                eval "require $route";
                my $obj = $route->new({});
                my $context = SpaceBotWar::WebSocket::Context->new({
                    room            => $room,
                    connection      => $connection,
                    content         => $content,
                    client_code         => $client_code,
                    user            => $user,
                });
                $self->log->debug("Call [$obj][$method]");
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
                $self->report_error($connection, \@error);

           }
       }
   );
   $connection->on(
       finish => sub {
           undef $connection;
           $self->log->info("bye");
       },
   );
}

sub report_error {
    my ($self, $connection, $error) = @_;

    my $msg = {
        route   => $path,
        room    => $room,
        content => {
            code        => $error->[0],
            message     => $error->[1],
            data        => $error->[2],
            msg_id      => $msg_id,
        },
    };
    $msg = JSON->new->encode($msg);
    $self->log->info("SEND: $msg");
    $connection->send($msg);
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

#!/usr/bin/env perl

use strict;
use warnings;

use Plack::App::WebSocket;
use Plack::Builder;
use Data::Dumper;
use JSON;

my $app = builder {
    mount "/ws" => Plack::App::WebSocket->new(
        on_error => sub {
            my $env = shift;

            return [
                500,
                ["Content-Type" => "text/plain"],
                ["Error: ". $env->{"plack.app.websocket.error"}],
            ];
        },
        on_establish => sub {
            my ($connection) = @_;
            #print STDERR "Connection established [".Dumper($connection)."]\n";
            #print STDERR Dumper(\%ENV);

            $connection->on(
                message => sub {
                    my ($connection, $msg) = @_;
                    print STDERR "SEND: $msg\n";
                    my $json = eval {decode_json($msg)};
                    if ($@) {
                        $connection->send(' { "error" : '.$@.' } ');
                    }
                    else {
                        my $send = {
                            route   => $json->{route},
                            method  => $json->{method},
                            content => { foo => 'bar' },
                        };
                        $connection->send(encode_json($send));
                    }
                    #$connection->send($msg);
                }
            );
            $connection->on(
                finish => sub {
                    undef $connection;
                    warn "Bye!!\n";
                },
            );
        }
    )->to_app;

};
print STDERR "Got here\n";
print STDERR Dumper($app);

$app;


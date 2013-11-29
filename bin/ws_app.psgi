#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket;
use Plack::Builder;
use Data::Dumper;
use JSON;

my $app = builder {
    mount "/ws" => SpaceBotWar::WebSocket->new->to_app;
};
print STDERR "Got here\n";
print STDERR Dumper($app);

$app;


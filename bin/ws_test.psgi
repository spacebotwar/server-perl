#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket::Test;
use SpaceBotWar::Queue;
use SpaceBotWar::Redis;
use Log::Log4perl;
use Redis;

use Plack::Builder;
use Plack::App::IndexFile;

#--- Initialize singleton objects
#
SpaceBotWar::Queue->initialize({
    server  => 'localhost:11300',
    ttr     => 120,
    debug   => 0,
});

my $redis = Redis->new(server => 'localhost:6379');
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

Log::Log4perl->init('/Users/icydee/sandbox/space-bot-war/log4perl.conf');


my $app = builder {
    mount "/ws/start"           => SpaceBotWar::WebSocket::Test->new({ room => 'Test'    })->to_app;
};
$app;


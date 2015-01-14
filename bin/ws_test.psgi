#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket::User;
use SpaceBotWar::Queue;
use SpaceBotWar::Redis;
use SpaceBotWar::Config;
use Log::Log4perl;
use Redis;

use Plack::Builder;
use Plack::App::IndexFile;

#--- Initialize singleton objects
#
SpaceBotWar::Config->initialize({
    filename => '/Users/icydee/sandbox/space-bot-war/spacebotwar.conf',
});

SpaceBotWar::Queue->initialize({
    server  => 'localhost:11300',
    ttr     => 120,
    debug   => 0,
});

my $redis = Redis->new(server => 'localhost:6379');
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

my $_db = SpaceBotWar::DB->connect(
    'DBI:mysql:sbw',
    'root',
    '', {
        mysql_enable_utf8   => 1,
        AutoCommit          => 1,
    },
);
SpaceBotWar::SDB->initialize({
    db => $db,
});

Log::Log4perl->init('/Users/icydee/sandbox/space-bot-war/log4perl.conf');

my $app = builder {
    mount "/ws"           => SpaceBotWar::WebSocket::User->new({ room => 'Test'    })->to_app;
};
$app;


#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use Redis;

use SpaceBotWar::WebSocket::Start;
use SpaceBotWar::WebSocket::User;
use SpaceBotWar::Queue;
use SpaceBotWar::Config;
use SpaceBotWar::Redis;
use SpaceBotWar::SDB;
use SpaceBotWar::DB;

use Log::Log4perl;

use Plack::Builder;
use Plack::App::IndexFile;
use Plack::Middleware::Headers;

# Initialize the singletons
#

# Connect to the Redis Docker image
#
my $redis = Redis->new(server => "192.168.99.100:6379");
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

SpaceBotWar::Config->initialize;

# Connect to the beanstalk Docker image
#
SpaceBotWar::Queue->initialize({
    server      => "192.168.99.100:11300",
    
});

# Connect to the mysql Docker image
#
my $dsn = "dbi:mysql:sbw:192.168.99.100:3306";

my $db = SpaceBotWar::DB->connect(
    $dsn,
    'sbw',
    'sbw', {
        mysql_enable_utf8   => 1,
        AutoCommit          => 1,
    },
);
SpaceBotWar::SDB->initialize({
    db => $db,
});


Log::Log4perl->init('/opt/code/etc/log4perl.conf');

# Each of these 'servers' can potentially be on separate servers and we can add new servers to increase capacity
#   'start'     - Should always be present, it is the first place to connect to
#   'lobby'     - Entry point to the chat system. The first place to connect to
#   'arena'     - Entry point for the Arena system. The first place to connect to
#
#   Each of these three main sections will maintain a list of other servers to connect to for
#   the 'game', the 'chat' and the 'match' servers of which there can be many.
#
my $app = builder {
    enable 'Headers',
        set     => ['Access-Control-Allow-Origin' => 'http://spacebotwar.com:8080'];
    enable 'Headers',
        set     => ['Access-Control-Allow-Credentials' => 'true'];
    # the 'start' of the game, where you go to get connection to a game server.
    mount "/ws/start"           => SpaceBotWar::WebSocket::Start->new({ server => 'Kingsley'    })->to_app;
    mount "/ws/user"            => SpaceBotWar::WebSocket::User->new({ server => 'Livingstone'  })->to_app;

    mount "/"                   => Plack::App::IndexFile->new(root => "/opt/code/src")->to_app;

};
$app;


#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket::Start;
use SpaceBotWar::WebSocket::Game;
use SpaceBotWar::WebSocket::Chat;
use SpaceBotWar::WebSocket::Arena;
use SpaceBotWar::WebSocket::Match;
use Plack::Builder;

# Each of these 'rooms' can potentially be on separate servers and we can add new rooms to increase capacity
#
my $app = builder {
    mount "/ws/start"           => SpaceBotWar::WebSocket::Start->new({ room => 'lobby'  })->to_app;
    mount "/ws/game"            => SpaceBotWar::WebSocket::Game->new({  room => 'lobby'  })->to_app;
    mount "/ws/chat"            => SpaceBotWar::WebSocket::Chat->new({  room => 'lobby'  })->to_app;
    mount "/ws/arena"           => SpaceBotWar::WebSocket::Arena->new({ room => 'lobby'  })->to_app;
    mount "/ws/match/gold"      => SpaceBotWar::WebSocket::Match->new({ room => 'gold'   })->to_app;
    mount "/ws/match/silver"    => SpaceBotWar::WebSocket::Match->new({ room => 'silver' })->to_app;
};
$app;


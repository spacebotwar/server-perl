#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket;
use SpaceBotWar::WebSocket::Game;
use SpaceBotWar::WebSocket::Chat;
use SpaceBotWar::WebSocket::Arena;

use Plack::Builder;

# Each of these 'rooms' can potentially be on separate servers and we can add new rooms to increase capacity
#
my $app = builder {
    mount "/ws/game/room_1"     => SpaceBotWar::WebSocket::Game->new({    room => 'room_1'    })->to_app;
    mount "/ws/chat/help"       => SpaceBotWar::WebSocket::Chat->new({    room => 'help'      })->to_app;
    mount "/ws/chat/general"    => SpaceBotWar::WebSocket::Chat->new({    room => 'general'   })->to_app;
    mount "/ws/arena/arena_1"   => SpaceBotWar::WebSocket::Arena->new({   room => 'arena_1'   })->to_app;
    mount "/ws/game/lobby"      => SpaceBotWar::WebSocket::Game->new({    room => 'lobby'     })->to_app;
    mount "/ws/chat/lobby"      => SpaceBotWar::WebSocket::Chat->new({    room => 'lobby'     })->to_app;
    mount "/ws/arena/lobby"     => SpaceBotWar::WebSocket::Arena->new({   room => 'lobby'     })->to_app;
};
$app;


#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket;

use Plack::Builder;

# Each of these 'rooms' can potentially be on separate servers and we can add new rooms to increase capacity
#
my $app = builder {
#    mount "/ws/game/room_1"     => SpaceBotWar::WebSocket->new({ room => 'room_1'    })->to_app;
#    mount "/ws/chat/help"       => SpaceBotWar::WebSocket->new({ room => 'help'      })->to_app;
#    mount "/ws/chat/general"    => SpaceBotWar::WebSocket->new({ room => 'general'   })->to_app;
#    mount "/ws/arena/arena_1"   => SpaceBotWar::WebSocket->new({ room => 'arena_1'   })->to_app;
    mount "/ws"      => SpaceBotWar::WebSocket->new({ room => 'main'     })->to_app;
#    mount "/ws/chat/lobby"      => SpaceBotWar::WebSocket->new({ room => 'lobby'     })->to_app;
#    mount "/ws/arena/lobby"     => SpaceBotWar::WebSocket->new({ room => 'lobby'     })->to_app;
};
$app;


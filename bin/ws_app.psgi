#!/usr/bin/env perl

use strict;
use warnings;
use lib "../lib";

use SpaceBotWar::WebSocket::Start;
use SpaceBotWar::WebSocket::Game;
use SpaceBotWar::WebSocket::Lobby;
use SpaceBotWar::WebSocket::Chat;
use SpaceBotWar::WebSocket::Arena;
use SpaceBotWar::WebSocket::Match;
use Plack::Builder;

# Each of these 'servers' can potentially be on separate servers and we can add new servers to increase capacity
#   'start'     - Should always be present, it is the first place to connect to
#   'lobby'     - Entry point to the chat system. The first place to connect to
#   'arena'     - Entry point for the Arena system. The first place to connect to
#
#   Each of these three main sections will maintain a list of other servers to connect to for
#   the 'game', the 'chat' and the 'match' servers of which there can be many.
#
my $app = builder {
    mount "/ws/start"           => SpaceBotWar::WebSocket::Start->new({ server => 'Kingsley'    })->to_app;
    mount "/ws/game/alpha"      => SpaceBotWar::WebSocket::Game->new({  server => 'Livingstone' })->to_app;
    mount "/ws/lobby"           => SpaceBotWar::WebSocket::Lobby->new({ server => 'Dickens'     })->to_app;
    mount "/ws/chat/bronte"     => SpaceBotWar::WebSocket::Chat->new({  server => 'Bronte'      })->to_app;
    mount "/ws/chat/Carroll"    => SpaceBotWar::WebSocket::Chat->new({  server => 'Carroll'     })->to_app;
    mount "/ws/arena"           => SpaceBotWar::WebSocket::Arena->new({ server => 'Franklin'    })->to_app;
    mount "/ws/match/rae"       => SpaceBotWar::WebSocket::Match->new({ server => 'Rae'         })->to_app;
    mount "/ws/match/scott"     => SpaceBotWar::WebSocket::Match->new({ server => 'Scott'       })->to_app;
};
$app;


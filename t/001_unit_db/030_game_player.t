use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Number::Delta;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::WebSocket::Player;


my $player = SpaceBotWar::WebSocket::Player->new({});




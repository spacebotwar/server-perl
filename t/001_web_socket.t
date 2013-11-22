use Test::More;
use Test::Mojo;

use FindBin;
use lib '../lib';
use SpaceBotWar;

my $t = Test::Mojo->new('SpaceBotWar');

$t->websocket_ok('/ws')
  ->send_ok('{"type" : "room", "content" : { "number" : 5 } }')
  ->message_ok
  ->message_is('{ foo: 0}');

done_testing();

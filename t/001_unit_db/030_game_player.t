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

isa_ok($player, 'SpaceBotWar::WebSocket::Player');
isa_ok($player, 'SpaceBotWar::WebSocket');

my $context = SpaceBotWar::WebSocket::Context->new({
    server      => 'Darwin',
    connection  => 'foo',
    client_code => 'bar',
    user        => 'baz',
});

my $content = {
    program_id  => '12345',
};

$context->content($content);

my $expected_reply = {
   'program' => {
      'created' => '2013-01-01 00:00:00',
      'author' => 'icydee',
      'id' => 456,
      'cloned_from' => 'foo',
      'author_id' => 123,
      'name' => 'Thunderball'
   },
   'message' => 'Program',
   'code' => 0
};

my $reply = $player->ws_init_program($context);

is_deeply($reply, $expected_reply);

$content = {
    player  => 0,
    ships   => [
        {id => 0, owner_id => 0},
        {id => 1, owner_id => 1},
    ]
};
$context->content($content);

$reply = $player->ws_game_state($context);

diag Dumper($reply);











diag Dumper($reply);


done_testing();

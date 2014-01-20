package SpaceBotWar::Game::Data;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use Log::Log4perl;

use namespace::autoclean;

# This defines the data that a player code has access to.

has 'my_ships'  => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ships::Mine]'
);

has 'enemy_ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ships::Enemy]'
);

has 'my_missiles' => (
    is      => 'rw',
#    isa     => 'ArrayRef[SpaceBotWar::Game::Missiles]'
);

has 'enemy_missiles' => (
    is      => 'rw',
#    isa     => 'ArrayRef[SpaceBotWar::Game::Missiles]'
);


__PACKAGE__->meta->make_immutable;

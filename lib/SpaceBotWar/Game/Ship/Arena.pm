package SpaceBotWar::Game::Ship::Arena;

use Moose;
use Log::Log4perl;

use namespace::autoclean;

# This defines a ship from the perspective of the Arena
# It can change some attributes that a player can't, e.g. 'x'
#

extends 'SpaceBotWar::Game::Ship';

# The status of the ship, e.g. 'ok' or 'dead'.
has 'status' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'ok',
);
# The health of the ship (0 to 100)
has 'health' => (
    is          => 'rw',
    isa         => 'Int',
    default     => 100,
);
# Current X co-ordinate
has 'x' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);
# Current Y co-ordinate
has 'y' => (
    is          => 'rw',
    isa         => 'Num',
    default     => 0,
);

__PACKAGE__->meta->make_immutable;

package SpaceBotWar::Game::Data;

use Moose;
use MooseX::Privacy;
use Data::Dumper;
use Log::Log4perl;

use namespace::autoclean;

# This defines the data that a player code has access to.

has 'my_ships'  => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ship::Mine]'
);

has 'enemy_ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ship::Enemy]'
);

has 'my_missiles' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Missile]'
);

has 'enemy_missiles' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Missile]'
);

has '_log' => (
    is      => 'rw',
    isa     => 'Str',
    default => '',
);

sub log {
    my ($self, $msg) = @_;

    if (defined $msg) {
        $self->_log($self->_log . $msg);
    }
    return $self->_log;
}




__PACKAGE__->meta->make_immutable;

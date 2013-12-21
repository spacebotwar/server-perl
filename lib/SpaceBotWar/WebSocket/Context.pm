package SpaceBotWar::WebSocket::Context;

use Moose;
use namespace::autoclean;

has 'room' => (
    is      => 'rw',
    isa     => 'Str',
);

has 'connection' => (
    is      => 'rw',
);

has 'content' => (
    is      => 'rw',
);

__PACKAGE__->meta->make_immutable;


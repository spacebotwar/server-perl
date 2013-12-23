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

has 'session' => (
    is      => 'rw',
#    isa     => 'Maybe[SpaceBotWar::Session]',
);

has 'user' => (
    is      => 'rw',
#    isa     => 'Maybe[SpaceBotWar::DB::Result::User]',
);

__PACKAGE__->meta->make_immutable;


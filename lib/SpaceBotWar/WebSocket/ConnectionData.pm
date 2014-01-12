package SpaceBotWar::WebSocket::ConnectionData;

use Moose;
use namespace::autoclean;

has 'connection' => (
    is      => 'rw',
);

__PACKAGE__->meta->make_immutable;


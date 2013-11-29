package SpaceBotWar::WebSocket::Chat;

use strict;
use warnings;

use parent qw(SpaceBotWar::WebSocket);
use AnyEvent::WebSocket::Server;

sub new {
    my ($class, @args) = @_;
    my $self = $class->SUPER::new(@args);
    $self->{websocket_server} = AnyEvent::WebSocket::Server->new();
    return $self;
}

1;

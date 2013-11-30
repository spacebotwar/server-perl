package SpaceBotWar::WebSocket::Game::Room::User;

use Moose;
use JSON;

use namespace::autoclean;


sub register {
    my ($self, $connection) = @_;

    my $send = {
        route   => "anything",
        self    => "$self",
        method  => "register",
        content => { foo => 'bar-boom', bubble => 'squeak'},
    };
    print STDERR "got here 2!\n";
    my $sent = JSON->new->encode($send);
    $connection->send($sent);
}

__PACKAGE__->meta->make_immutable;


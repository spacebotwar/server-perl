package SpaceBotWar::WebSocket::Game::Test;

use Moose;

sub ws_test {
    my ($self, $context) = @_;

    print STDERR "TEST: session [".$context->session->id."] user [".$context->user->id."]\n";
    return {
        code    => 0,
        message => "Success",
        test_session    => $context->session->id,
        test_user       => $context->user->id,
    };
}



__PACKAGE__->meta->make_immutable;


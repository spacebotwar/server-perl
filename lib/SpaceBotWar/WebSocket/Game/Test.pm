package SpaceBotWar::WebSocket::Game::Test;

use Moose;

sub ws_test {
    my ($self, $context) = @_;

    print STDERR "TEST: client_code [".$context->client_code->id."] user [".$context->user->id."]\n";
    return {
        code    => 0,
        message => "Success",
        test_client_code    => $context->client_code->id,
        test_user       => $context->user->id,
    };
}



__PACKAGE__->meta->make_immutable;


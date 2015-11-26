package SpaceBotWar::WebSocket::Game::Test;

use Moose;

sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger( $self );
}

sub ws_test {
    my ($self, $context) = @_;

    $self->log->debug("TEST: client_code [".$context->client_code->id."] user [".$context->user->id."]");
    return {
        code    => 0,
        message => "Success",
        test_client_code    => $context->client_code->id,
        test_user       => $context->user->id,
    };
}



__PACKAGE__->meta->make_immutable;


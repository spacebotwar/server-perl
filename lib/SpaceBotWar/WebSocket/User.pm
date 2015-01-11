package SpaceBotWar::WebSocket::User;

use Moose;

extends 'SpaceBotWar::WebSocket';

sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD: USER $self");
}

#--- Get or confirm that a client_code is valid
#
sub ws_client_code {
    my ($self, $context) = @_;

    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $context->content->{client_code},
    });
    my $message = "";
    # if the client code is valid, use it
    if ($client_code->is_valid) {
        $message = "GOOD Client Code";
    }
    else {
        $message = "NEW Client Code";
        $client_code->get_new_id;
    }

    return {
        code            => 0,
        message         => $message,
        client_code     => $client_code->id,
    };
}

1;

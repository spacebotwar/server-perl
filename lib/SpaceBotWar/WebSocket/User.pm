package SpaceBotWar::WebSocket::User;

use Moose;
use Log::Log4perl;
use Data::Dumper;

extends 'SpaceBotWar::WebSocket';

sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD: USER $self");
}

#--- Get or confirm that a client_code is valid
#
sub ws_client_code {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('SpaceBotWar::WebSocket::User');
    $log->debug("client_code");

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

#--- Register a new user
#
sub ws_register {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('SpaceBotWar::WebSocket::User');

    $log->debug("ws_register: ".Dumper($context));
    # validate the Client Code
    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $context->content->{client_code},
    })->assert_valid;

    return {
        code           => 1000,
        message        => "ERROR: bad client code",
    };
}


1;

package SpaceBotWar::WebSocket::User;

use Moose;
use Log::Log4perl;
use Data::Dumper;
use Text::Trim qw(trim);
use Email::Valid;

use SpaceBotWar::SDB;
use SpaceBotWar::Queue;

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
    my $db = SpaceBotWar::SDB->instance->db;

    $log->debug("ws_register: ".Dumper($context));
    # validate the Client Code
    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $context->content->{client_code},
    })->assert_valid;

    # Register the account
    my $user = $db->resultset('User')->assert_create({
        email       => $context->content->{email},
        username    => $context->content->{username},
        password    => $context->content->{password},
    });

    # Create a Job to send a registration email
    my $queue = SpaceBotWar::Queue->instance;
    $queue->publish('email_register', {
        username    => $user->username,
        email       => $user->email,
    });

    return {
        code           => 0,
        message        => "OK: Registered",
    };
}

#-- Forgot password
#
sub ws_forgot_password {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('SpaceBotWar::WebSocket::User');
    my $db = SpaceBotWar::SDB->instance->db;

    $log->debug("ws_forgot_password: ");
    # validate the Client Code
    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $context->content->{client_code},
    })->assert_valid;

    my $username_or_email = $context->content->{username_or_email} || "";
    trim $username_or_email;
    if ($username_or_email eq "") {
        confess [1002, "username_or_email is required" ];
    }

    # does username_or_email match an existing username or email
    my ($user) = $db->resultset('User')->search({
        -or     => [
            username    => $username_or_email,
            email       => $username_or_email,
        ]
    });
    if ($user) {
        # Create a Job to send a forgotten password email
        my $queue = SpaceBotWar::Queue->instance;
        $queue->publish('email_forgot_password', {
            username    => $user->username,
            email       => $user->email,
        });
    }

    return {
        code           => 0,
        message        => "OK",
    };
}

#-- Login with password
#
sub ws_login_with_password {
    my ($self, $context) = @_;

    my $log = Log::Log4perl->get_logger('SpaceBotWar::WebSocket::User');
    my $db = SpaceBotWar::SDB->instance->db;
    $log->debug(Dumper($context));

    $log->debug("ws_login_with_password: ");
    # validate the Client Code
    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $context->content->{client_code},
    })->assert_valid;

    $db->resultset('User')->assert_login_with_password({
        username    => $context->content->{username},
        password    => $context->content->{password},
    });

    return {
        code    => 0,
        message => "OK",
    }
}

1;

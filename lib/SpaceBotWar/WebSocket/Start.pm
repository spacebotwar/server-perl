package SpaceBotWar::WebSocket::Start;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;

# This is the common point into which everyone connects to. On this server
# it is possible to do the necessary commands to log in.
#

sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD");
}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH");
}

# Get a new client_code variable.
#
sub ws_get_client_code {
    my ($self, $context) = @_;

    my $client_code_id;
    if (SpaceBotWar::ClientCode->validate_client_code($context->content->{client_code})) {
        $client_code_id = $context->content->{client_code};
    }
    else {
        my $client_code = SpaceBotWar::ClientCode->create_client_code;
        $client_code_id = $client_code->id;
    }

    return {
        code        => 0,
        message     => "new Client Code",
        client_code   => $client_code_id,
    };
}


# Get the LoginRadius settings
#
sub ws_get_radius {
    my ($self, $context) = @_;

    return {
        code            => 0,
        message         => "radius api key",
        radius_api_key  => SpaceBotWar->config->get('radius/api_key'),
    };
}


# A User attempting to 'register' a new username and password
#
sub ws_register {
    my ($self, $context) = @_;

    SpaceBotWar::ClientCode->assert_validate_client_code($context->content->{client_code});
    my $db = SpaceBotWar->db;
    $db->resultset('User')->assert_username_available($context->content->{username});
    $db->resultset('User')->assert_email_valid($context->content->{email});
    $db->resultset('User')->assert_password_valid($context->content->{password});

    my $user = $db->resultset('User')->assert_create({ %{$context->content} });

    return {
        code    => 0,
        message => 'Available',
    };
}


# A user requests to be sent an email code due to forgotten password
#
sub ws_forgot_password {
    my ($self, $context) = @_;

    SpaceBotWar::ClientCode->assert_validate_client_code($context->content->{client_code});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_find_by_username_or_email($context->content->{username}, $context->content->{email});

    confess [9999, "Not yet implemented"];
    
    return {
        code        => 0,
        message     => 'Email code sent.',
    };
}


# A user logs in with a username and password
#
sub ws_login_with_password {
    my ($self, $context) = @_;

    my $client_code = SpaceBotWar::ClientCode->assert_validate_client_code($context->content->{client_code});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_login_with_password($context->content);
    $client_code->user_id($user->id);
    $client_code->logged_in(1);

    return {
        code        => 0,
        message     => 'Welcome',
        username    => $user->name,
    };
}

# Log in with an email code
#
sub ws_login_with_email_code {
    my ($self, $context) = @_;

    SpaceBotWar::EmailCode->assert_validate_email_code($context->content->{email_code});

    # email code login? Just recover the client_code user_id?

    return {
        code        => 0,
        message     => 'Welcome',
        username    => 'james',
    };
}



# Log out of an account
#
sub ws_logout {
    my ($self, $context) = @_;

    # What should a 'logout' do? Just set the cache value associated with
    # the Client Code?
    #
    return {
        code        => 0,
        message     => 'Good Bye',
    };
}


# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to Space Bot War!',
    };
}

1;

package SpaceBotWar::WebSocket::Start;

use Moose;
use MooseX::NonMoose;

extends 'SpaceBotWar::WebSocket';

use SpaceBotWar;
use SpaceBotWar::Session;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;

# This is the common point into which everyone connects to. In the
# lobby it is possible to do the necessary commands to log in, or
# register, to connect to public chat rooms etc. Once logged in
# the user will be directed to other rooms.
#


# Get a new session variable.
#
sub ws_get_session {
    my ($self, $context) = @_;

    my $session = SpaceBotWar::Session->create_session;

    return {
        code    => 0,
        message => "new session",
        session => $session->id,
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

    SpaceBotWar::Session->assert_validate_session($context->content->{session});
    my $db = SpaceBotWar->db;
    $db->resultset('User')->assert_username_available($context->content->{username});
    $db->resultset('User')->assert_email_valid($context->content->{email});
    $db->resultset('User')->assert_password_valid($context->content->{password});

    my $user = $db->resultset('User')->assert_create({ %{$context->content} });

    return {
        code    => 0,
        message => 'Available',
        data    => $context->content->{username},
    };
}


# A user requests to be sent an email code due to forgotten password
#
sub ws_confirm_email {
    my ($self, $context) = @_;

    SpaceBotWar::Session->assert_validate_session($context->content->{session});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_confirm_email($context->content->{code});

    return {
        code        => 0,
        message     => 'Email code sent.',
        data        => $user->name,
    };
}


# A user logs in with a username and password
#
sub ws_login_with_password {
    my ($self, $context) = @_;

    my $session = SpaceBotWar::Session->assert_validate_session($context->content->{session});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_login_with_password($context->content);
    $session->user_id($user->id);
    $session->logged_in(1);

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

    # email code login? Just recover the session user_id?

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
    # the session ID?
    #
    return {
        code        => 0,
        message     => 'Good Bye',
    };
}


# A user has joined the room
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to the lobby',
        data        => 'lobby',
    };
}

1;

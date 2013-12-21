package SpaceBotWar::WebSocket::Game;

use strict;
use warnings;
use SpaceBotWar;
use SpaceBotWar::Session;

use Carp;
use UUID::Tiny ':std';

use parent qw(SpaceBotWar::WebSocket);

# This is the Game Lobby where people connect to to obtain the room
# (server) they need to connect to
#


sub render_json {
    my ($self, $room, $connection, $json) = @_;

    my $sent = JSON->new->encode($json);
    print STDERR "SEND: [$sent]\n";


    $connection->send($sent);
}

# Get a new session variable.
#
sub ws_get_session {
    my ($self, $context) = @_;

    my $new_session = SpaceBotWar::Session->create_session;

    my $send = {
        room    => $context->room,
        route   => "/get_session",
        content => {
            code    => 0,
            message => "new session",
            session => $new_session,
        }
    };
    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
}


# Get the LoginRadius settings
#
sub ws_get_radius {
    my ($self, $context) = @_;

    my $send = {
        room    => $context->room,
        route   => "/get_radius",
        content => {
            code            => 0,
            message         => "radius api key",
            radius_api_key  => SpaceBotWar->config->get('radius/api_key'),
        },
    };
    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
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

    my $send = {
        room    => $context->room,
        route   => "/register",
        content => {
            code    => 0,
            message => 'Available',
            data    => $context->content->{username},
        },
    };
    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
}


# A user sends an email 'validation code' to the server
#
sub ws_confirm_email {
    my ($self, $context) = @_;

    SpaceBotWar::Session->assert_validate_session($context->content->{session});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_confirm_email($context->content->{code});

    my $send = {
        room    => $context->room,
        route   => '/confirm_email',
        content => {
            code        => 0,
            message     => 'Logged in',
            data        => $user->name,
        },
    };
    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
}


# A user logs in with a username and password
#
sub ws_login_with_password {
    my ($self, $context) = @_;

    SpaceBotWar::Session->assert_validate_session($context->content->{session});
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_login_with_password($context->content);

    my $send = {
        room    => $context->room,
        route   => '/login_with_password',
        content => {
            code        => 0,
            message     => 'Welcome',
            username    => $user->name,
        }    
    };

    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
}

# Log in with an email code
#
sub ws_login_with_email_code {
    my ($self, $context) = @_;

    SpaceBotWar::EmailCode->assert_validate_email_code($context->content->{email_code});

    # email code login? Just recover the session user_id?

    my $send = {
        room    => $context->room,
        route   => '/login_with_email_code',
        content => {
            code        => 0,
            message     => 'Welcome',
            username    => 'james',
        }
    };

    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);
}



# Log out of an account
#
sub ws_logout {
    my ($self, $context) = @_;

    # What should a 'logout' do? Just set the cache value associated with
    # the session ID?
    #
    my $send = {
        room    => $context->room,
        route   => '/logout',
        content => {
            code        => 0,
            message     => 'Good Bye',
        }
    };

    if ($context->content->{id}) {
        $send->{content}{id} = $context->content->{id};
    }
    $self->render_json($context->room, $context->connection, $send);

}


# A user has joined the room
#
sub on_connect {
    my ($self, $room, $connection) = @_;

    my $send = {
        room    => $room,
        route   => "/lobby",
        content => {
            code        => 0,
            message     => 'Welcome to the game lobby',
            data        => 'lobby',
        },
    };
    $self->render_json($room, $connection, $send);
}





1;

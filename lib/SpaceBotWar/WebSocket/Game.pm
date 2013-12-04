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
    print STDERR "RENDER_JSON: [$sent]\n";


    $connection->send($sent);
}

# Get a new session variable.
#
sub ws_get_session {
    my ($self, $room, $connection, $content) = @_;

    my $new_session = SpaceBotWar::Session->create_session;

    my $send = {
        room    => $room,
        route   => "/get_session",
        content => {
            code    => 0,
            message => "new session",
            session => $new_session,
        }
    };
    if ($content->{id}) {
        $send->{content}{id} = $content->{id};
    }
    $self->render_json($room, $connection, $send);
}



# A User attempting to 'register' a new username and password
#
sub ws_register {
    my ($self, $room, $connection, $content) = @_;

    my $db = SpaceBotWar->db;

    $db->resultset('User')->assert_username_available($content->{username});
    $db->resultset('User')->assert_email_valid($content->{email});
    $db->resultset('User')->assert_password_valid($content->{password});

    my $user = $db->resultset('User')->assert_create({ %$content });

    my $send = {
        room    => $room,
        route   => "/register",
        content => {
            code    => 0,
            message => 'Available',
            data    => $content->{username},
        },
    };
    if ($content->{id}) {
        $send->{content}{id} = $content->{id};
    }
    $self->render_json($room, $connection, $send);
}


# A user sends an email 'validation code' to the server
#
sub ws_confirm_email {
    my ($self, $room, $connection, $content) = @_;

    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_confirm_email($content->{code});

    my $send = {
        room    => $room,
        route   => '/confirm_email',
        content => {
            code        => 0,
            message     => 'Logged in',
            data        => $user->name,
        },
    };
    if ($content->{id}) {
        $send->{content}{id} = $content->{id};
    }
    $self->render_json($room, $connection, $send);
}


# A user logs in with a username and password
#
sub ws_login_with_password {
    my ($self, $room, $connection, $content) = @_;

    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_login_with_password($content);

    my $send = {
        room    => $room,
        route   => '/login_with_password',
        content => {
        }    
    };

    if ($content->{id}) {
        $send->{content}{id} = $content->{id};
    }
    $self->render_json($room, $connection, $send);
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

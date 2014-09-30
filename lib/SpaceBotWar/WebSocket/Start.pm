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
use Try;
use Data::Dumper;

# This is the common point into which everyone connects to. On this server
# it is possible to do the necessary commands to log in.
#

sub BUILD {
    my ($self) = @_;

    $self->log->info("BUILD START ###### $self");
}

sub DESTROY {
    my ($self) = @_;

    $self->log->debug("DESTROY: START #### $self");
}

sub DEMOLISH {
    my ($self) = @_;

    $self->log->info("DEMOLISH: START #### $self");
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
        message         => "LoginRadius API key",
        radius_api_key  => SpaceBotWar->config->get('radius/api_key'),
    };
}


# A User attempting to 'register' a new username and password
#
sub ws_register {
    my ($self, $context) = @_;

    $self->check_client_code($context);
    my $db = SpaceBotWar->db;
    my $rs_user = $db->resultset('User');
    my $user = $rs_user->assert_create({ %{$context->content} });

    # Send a registration email to the user
    #
    my $queue = SpaceBotWar->queue;
    my $job = $queue->publish('send_email', {
        task        => 'registration',
        user_id     => $user->id,
    },{
        priority    => 1000,
    });
    $self->log->debug("Send Registration Email. Job ID : ".$job->id);

    return {
        code    => 0,
        message => 'Available',
    };
}


# A user requests to be sent an email code due to forgotten password
#
sub ws_forgot_password {
    my ($self, $context) = @_;
 
    $self->check_client_code($context);
    my $db = SpaceBotWar->db;
    my $user;

    $self->log->debug("Forgot password!");
    try {
        $user = $db->resultset('User')->assert_find_by_username_or_email($context->content->{username_or_email});
    };
  

    if ($user) {
        # Put a job on the send_email queue to send a forgotten password reminder email
        #
        my $queue = SpaceBotWar->queue;
        my $job = $queue->publish('send_email', {
            task        => 'forgot_password',
            user_id     => $user->id,
        },{
            priority    => 1000,
        });
        $self->log->debug("Send Password Reminder Email. Job ID : ".$job->id);
    }
    else {
        $self->log->debug("Could not find user with those details! [".$context->content->{username_or_email}."]");
    }
    
    return {
        code        => 0,
        message     => 'Success',
    };
}


# A user logs in with a username and password
#
sub ws_login_with_password {
    my ($self, $context) = @_;

    my $client_code = $self->check_client_code($context);   
    my $db = SpaceBotWar->db;

    my $user = $db->resultset('User')->assert_login_with_password($context->content);
    $client_code->user_id($user->id);
    $client_code->logged_in(1);

    return {
        code        => 0,
        message     => 'Welcome',
        username    => $user->username,
    };
}

# Log in with an email code. Must specify a new password to use
#
sub ws_login_with_email_code {
    my ($self, $context) = @_;

    my $log = $self->log;
    my $client_code = $self->check_client_code($context);
    my $email_code  = $context->content->{email_code};
    $log->debug("Log in with email code [$email_code]");
    # See if the email code is in the cache
    $email_code = SpaceBotWar::EmailCode->new({
        id      => $email_code,
    });
    $email_code->assert_validate;
    $log->debug("Email code is valid. user_id=[".$email_code->user_id."]");

    my $password = $context->content->{new_password};
    my $db = SpaceBotWar->db;

    $db->resultset('User')->assert_password_valid($password);

    # If the email code is valid (and has not timed out) then it should now contain the user_id
    #
    $self->log->debug(Dumper($email_code));

    if ($email_code->user_id) {
        my $user = SpaceBotWar->db->resultset('User')->assert_id($email_code->user_id);
        $user->password($password);
        $user->update;
        return {
            code        => 0,
            message     => 'Welcome',
            username    => $user->username,
        }
    }
    return {
        code        => 1000,
        message     => 'Error',
    };
}



# Log out of an account
#
sub ws_logout {
    my ($self, $context) = @_;

    # This should do it, right?
    my $client_code = $self->check_client_code($context);
    $client_code->logged_in(0);

    return {
        code        => 0,
        # Shamelessly stolen from Youtube: http://youtu.be/Ex2NNUVE8V4?t=2m30s
        # By all means change the code, but make sure the tests still work?
        message     => 'Good Bye',
#        message     => 'So long, see ya sucka, bon voyage, arriverderci, later loser, goodbye, good riddance, let the doorknob hit ya where the good Lord split ya, don\'t come back around here no more, hasta la vista, kick rocks, and get the hell out. Woopsie! Did I say that aloud? :O',
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

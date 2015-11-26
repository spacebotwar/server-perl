package UnitTestsFor::SpaceBotWar::WebSocket::User;

use lib "lib";
use lib "t/lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';
use Test::Exception;
use Data::Dumper;
use Log::Log4perl;

use SpaceBotWar::WebSocket::User;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;

use UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures;

sub test_construction {
    my ($self) = @_;

    my $ws_user = SpaceBotWar::WebSocket::User->new;
    isa_ok($ws_user, 'SpaceBotWar::WebSocket::User');
}

sub test_client_code {
    my ($self) = @_;

    my $content = {
        msg_id      => '123',
        client_code => 'invalid',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content => $content,
    });

    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client_code should return a valid one
    #
    my $response = $ws_user->ws_client_code($context);
    is($response->{code},           0,                  "Response: code");
    is($response->{message},        "NEW Client Code",  "Response: message");
    isnt($response->{client_code},  'invalid',          "Response: client_code changed");
    isnt($context->client_code,     undef,              "There is a client code");
    isa_ok($context->client_code,   "SpaceBotWar::ClientCode");

    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $response->{client_code},
    });

    is($client_code->is_valid, 1, "Client Code is valid");
    
    # change the content in the context to use a valid client code
    $content->{msg_id}      = 124;
    $content->{client_code} = $client_code->id;

    $response = $ws_user->ws_client_code($context);
    is($response->{code},           0,                  "Response: code");
    is($response->{message},        "GOOD Client Code", "Response: message");
    is($response->{client_code},    $client_code->id,   "Response: client_code unchanged");
    isnt($context->client_code,     undef,              "there is a client code");
    is($context->client_code->id,   $client_code->id,   "Same client_code");
}

sub test_register {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        msg_id      => 456,
        client_code => '123',
        username    => 'joe3',
        email       => 'joe3@example.com',
        password    => 'TopS3kret',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    my $client_code = SpaceBotWar::ClientCode->new;
    $content->{client_code} = $client_code->id;

    # Missing or too short a username should throw an error
    my @user_tests = ('', qw(a ab ));
    foreach my $username (@user_tests) {
        $content->{username} = $username;
        throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, no username [$username]";
        is($@->[0], 1001, "Code, too short a username");
        like($@->[1], qr/^Username must be at least 3 characters long/, "Message, username too short"); 
    }
    $content->{username} = 'bert';

    # A missing email should throw an error
    delete $content->{email};
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'Throw, no email';
    is($@->[0], 1001, "Code, no email");
    like($@->[1], qr/^Email is missing/, "Message, no email");
   
    # Various invalid email addresses
    my @bad_emails = (
        'foo',
        'bar@',
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa@example.com',
    );
    foreach my $email (@bad_emails) {
        $content->{email} = $email;
        throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, bad email [$email]";
        is($@->[0], 1001, "Code, bad email");
        like($@->[1], qr/^Email is invalid/, "Message, bad email");
    }
    $content->{email} = 'me@example.com';

    my $db = SpaceBotWar::SDB->db;
    my $fixtures = UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures->new( { schema => $db } );
    $fixtures->load('user_albert');

    # Username should not already be in use
    $content->{username} = 'bert';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing username";
    is($@->[0], 1001, "Code, existing username");
    like($@->[1], qr/^Username not available/, "Message, username already in use");

    # Email address should not already be in use
    $content->{username} = 'joe90';
    $content->{email} = 'bert@example.com';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing email";
    is($@->[0], 1001, "Code, existing email");
    like($@->[1], qr/^Email is not available/, "Message, email already in use");
    $content->{email} = 'joe@example.com';

    # Password should not be too short
    $content->{password} = 'T1ny';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, short password";
    is($@->[0], 1001, "Code, password too short");
    like($@->[1], qr/^Password must be at least 5 characters long/, "Message, password is too short");

    # Password should contain upper case characters
    $content->{password} = 'onlylow3r';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, password has no upper case";
    is($@->[0], 1001, "Code, password has no upper case characters");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no upper case characters");

    # Password should contain lower case characters
    $content->{password} = '0NLYUPR';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, password has no lower case";
    is($@->[0], 1001, "Code, password has no lower case characters");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no lower case characters");

    # Password should contain numeric characters
    $content->{password} = 'noNumBers';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, password has no numbers";
    is($@->[0], 1001, "Code, password has no numbers");
    like($@->[1], qr/^Password must contain numbers, lowercase and uppercase/, "Message, password has no numeric characters");

    $content->{password} = 'TopS3cr3t';

    # A good client code, username, email and password should now work...
    my $response;
    if (lives_ok { $response = $ws_user->ws_register($context) } 'good client code' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK: Registered",           "Response: message registered");
    }
    else {
        diag(Dumper($@));
    }

    # A registration should have put a job on the job queue
    my $queue = SpaceBotWar::Queue->instance;
    my $job = $queue->peek_ready;
    isnt($job, undef, "Job is ready"); 
    #diag(Dumper($job));
    $queue->delete($job->job->id);

    $fixtures->unload;
}


sub test_forgot_password {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        msg_id              => 457,
        client_code         => 'rubbish',
        username_or_email   => 'joe',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_forgot_password($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $content->{client_code} = SpaceBotWar::ClientCode->new->id;

    my $db = SpaceBotWar::SDB->db;
    my $fixtures = UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures->new( { schema => $db } );
    $fixtures->load('user_albert');

    # Blank username or email should return error
    $content->{username_or_email} = "   ";
    throws_ok { $ws_user->ws_forgot_password($context) } qr/^ARRAY/, "Throw, username/email is blank";
    is($@->[0], 1002, "Code, username/email is blank");
    like($@->[1], qr/^username_or_email is required/, "Message, username_or_email is required");

    # non-existing username or email should return success
    $content->{username_or_email} = "username_unknown";
    my $response = $ws_user->ws_forgot_password($context);
    is($response->{code}, 0, "Response: code good");
    is($response->{message}, "OK", "Response: message OK");

    # but no email job should be raised
    my $queue = SpaceBotWar::Queue->instance;
    my $job = $queue->peek_ready;
    is($job, undef, "No email job"); 
 
    # existing username should return success
    $content->{username_or_email} = "bert";
    if ( lives_ok { $response = $ws_user->ws_forgot_password($context) } 'good client code' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }
    # email job should be raised
    $job = $queue->peek_ready;
    isnt($job, undef, "Email Job should be raised");
    $queue->delete($job->job->id);

    # existing email should return success
    $content->{username_or_email} = 'bert@example.com';
    if ( lives_ok { $response = $ws_user->ws_forgot_password($context) } 'good client code' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }
    # email job should be raised
    $job = $queue->peek_ready;
    isnt($job, undef, "Email Job should be raised");
    $queue->delete($job->job->id);

    # Job queue should now be empty
    $job = $queue->peek_ready;
    is($job, undef, "No more jobs");

    $fixtures->unload;

}

sub test_login_with_password {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        msg_id              => 458,
        client_code         => 'incorrect',
        username            => 'bert',
        password            => 'secret',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content     => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_login_with_password($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $content->{client_code} = SpaceBotWar::ClientCode->new->id;

    my $db = SpaceBotWar::SDB->db;
    my $fixtures = UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures->new( { schema => $db } );
    $fixtures->load('user_albert');

    # No client_code should return an error
    $content->{client_code} = "";
    throws_ok { $ws_user->ws_login_with_password($context) } qr/^ARRAY/, "Throw, client code is blank";
    is($@->[0], 1001, "Code, no client code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $content->{client_code} = SpaceBotWar::ClientCode->new->id;

    # No matching username should return an error
    $content->{username} = "someone_else";
    throws_ok { $ws_user->ws_login_with_password($context) } qr/^ARRAY/, "Throw, unknown username";
    is($@->[0], 1001, "Code, Unknown username");
    like($@->[1], qr/^Incorrect credentials 1/, "Message");
    $content->{username} = 'bert';

    # No matching password should return an error
    $content->{password} = "hack_attack";
    throws_ok { $ws_user->ws_login_with_password($context) } qr/^ARRAY/, "Throw, incorrect password";
    is($@->[0], 1001, "Code, Incorrect Password");
    like($@->[1], qr/^Incorrect credentials 2/, "Message");
    $content->{password} = 'secret';

    # Correct username and password should log in
    my $response;
    if ( lives_ok { $response = $ws_user->ws_login_with_password($context) } 'good login' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }
    is($context->user->id, 1, "Correct user id");
    $fixtures->unload;
}

sub test_login_with_email_code {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $email_code = SpaceBotWar::EmailCode->new({ user_id => 1 });

    my $content = {
        msg_id              => 467,
        client_code         => 'incorrect',
        email_code          => $email_code->id,
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content     => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_login_with_email_code($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $content->{client_code} = SpaceBotWar::ClientCode->new->id;

    my $db = SpaceBotWar::SDB->db;
    my $fixtures = UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures->new( { schema => $db } );
    $fixtures->load('user_albert');

    # No email_code should return an error
    $content->{email_code} = "";
    throws_ok { $ws_user->ws_login_with_email_code($context) } qr/^ARRAY/, "Throw, email code is blank";
    is($@->[0], 1001, "Code, no email code");
    like($@->[1], qr/^Invalid Email Code/, "Message");

    # No matching email_code should return an error
    $content->{email_code} = "something_else";
    throws_ok { $ws_user->ws_login_with_email_code($context) } qr/^ARRAY/, "Throw, unknown email_code";
    is($@->[0], 1001, "Code Invalid Email Code");
    like($@->[1], qr/^Invalid Email Code/, "Message");

    # Correct email code should return success
    $content->{email_code} = $email_code->id;
    my $response;
    if ( lives_ok { $response = $ws_user->ws_login_with_email_code($context) } 'good login' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }
    is($context->user->id, 1, "Correct user id");
    $fixtures->unload;
}

sub test_logout {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        msg_id              => 467,
        client_code         => 'incorrect',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content     => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_logout($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");
    $content->{client_code} = SpaceBotWar::ClientCode->new->id;

    my $db = SpaceBotWar::SDB->db;
    my $fixtures = UnitTestsFor::SpaceBotWar::WebSocket::User::Fixtures->new( { schema => $db } );
    $fixtures->load('user_albert');

    # If you are not logged in, it should return success
    my $response;
    if ( lives_ok { $response = $ws_user->ws_logout($context) } 'good login' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }

    # If you *are* logged in, it should return success
    $content = {
        msg_id              => 458,
        client_code         => SpaceBotWar::ClientCode->new->id,
        username            => 'bert',
        password            => 'secret',
    };
    $context->content($content);

    unless (lives_ok { $response = $ws_user->ws_login_with_password($context) } 'good login' ) {
        fail('User failed to log on');
        diag(Dumper($@));
    }

    is($context->user->id, 1, "First check user is logged on");

    if ( lives_ok { $response = $ws_user->ws_logout($context) } 'good login' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK",                       "Response: message good");
    }
    else {
        diag(Dumper($@));
    }

    is($context->user, undef, "User is logged out");
    $fixtures->unload;
}
1;

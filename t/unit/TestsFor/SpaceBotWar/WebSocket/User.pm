package TestsFor::SpaceBotWar::WebSocket::User;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';
use Test::Exception;
use Data::Dumper;
use Log::Log4perl;

use SpaceBotWar::WebSocket::User;
use SpaceBotWar::ClientCode;

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
}

sub test_register {
    my ($self) = @_;

    my $log = Log::Log4perl->get_logger(__PACKAGE__);

    my $content = {
        msg_id      => 456,
        client_code => '123',
        username    => 'joe3',
        email       => 'joe3@example.com',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should throw an error
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'test throw 1';
    is($@->[0], 1001, "Code");
    like($@->[1], qr/^Client Code is invalid/, "Message");


    # A good client code
    my $client_code = SpaceBotWar::ClientCode->new;
    $content->{client_code} = $client_code->id;
    my $response;
    if (lives_ok { $response = $ws_user->ws_register($context) } 'good client code' ) {
        is($response->{code},       0,                          "Response: code good");
        is($response->{message},    "OK: Registered",           "Response: message registered");
    }
    else {
        diag(Dumper($@));
    }

    # A missing username should throw an error
    delete $content->{username};
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'Throw, no username';
    is($@->[0], 1002, "Code, no username");
    like($@->[1], qr/^Username is missing/, "Message, no username"); 
    $content->{username} = 'bert';

    # A missing email should throw an error
    delete $content->{email};
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, 'Throw, no email';
    is($@->[0], 1002, "Code, no email");
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
        is($@->[0], 1003, "Code, bad email");
        like($@->[1], qr/^Email is invalid/, "Message, bad email");
    }
    $content->{email} = 'me@example.com';

    # Username should not already be in use
    my $db = SpaceBotWar::SDB->db;
    $db->resultset('User')->create({
        username    => 'bert',
        password    => 'secret',
        email       => 'bert@example.com',
    });
    $content->{username} = 'bert';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing username";
    is($@->[0], 1004, "Code, existing username");
    like($@->[1], qr/^Username already in use/, "Message, username already in use");

    # Email address should not already be in use
    $content->{username} = 'joe90';
    $content->{email} = 'bert@example.com';
    throws_ok { $ws_user->ws_register($context) } qr/^ARRAY/, "Throw, existing email";
    is($@->[0], 1004, "Code, existing email");
    like($@->[1], qr/^Email already in use/, "Message, email already in use");
}


1;


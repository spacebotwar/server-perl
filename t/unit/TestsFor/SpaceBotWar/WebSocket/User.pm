package TestsFor::SpaceBotWar::WebSocket::User;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';

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

    my $content = {
        msg_id      => 456,
        client_code => '123',
    };
    my $context = SpaceBotWar::WebSocket::Context->new({
        content => $content,
    });
    my $ws_user = SpaceBotWar::WebSocket::User->new;

    # An invalid client code should return an error
    my $response = $ws_user->ws_register($context);
    is($response->{code},       1000,                       "Response: code");
    is($response->{message},    "ERROR: bad client code",   "Response: message");

    # A good client code
    my $client_code = SpaceBotWar::ClientCode->new;
    $content->{client_code} = $client_code->id;

    $response = $ws_user->ws_register($context);
    is($response->{code},       0,                          "Response: code good");
    is($response->{message},    "OK: registered",           "Response: message registered");


}


1;


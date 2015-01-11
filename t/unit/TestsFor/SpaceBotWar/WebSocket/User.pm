package TestsFor::SpaceBotWar::WebSocket::User;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';

use SpaceBotWar::WebSocket::User;
use SpaceBotWar::ClientCode;

sub test_construction {
    my ($self) = @_;

    my $user = SpaceBotWar::WebSocket::User->new;
    isa_ok($user, 'SpaceBotWar::WebSocket::User');
}

sub test_client_code {
    my ($self) = @_;

    my $context = SpaceBotWar::WebSocket::Context->new({
        content => {
            msg_id      => '123',
            client_code => 'invalid',
        }
    });

    my $user = SpaceBotWar::WebSocket::User->new;

    # An invalid client_code should return a valid one
    #
    my $response = $user->ws_client_code($context);
    is($response->{code},           0,                  "Response: code");
    is($response->{message},        "NEW Client Code",  "Response: message");
    isnt($response->{client_code},  'invalid',          "Response: client_code changed");

    my $client_code = SpaceBotWar::ClientCode->new({
        id      => $response->{client_code},
    });

    is($client_code->is_valid, 1, "Client Code is valid");
    
    # now use a valid client code
    $context = SpaceBotWar::WebSocket::Context->new({
        content => {
            msg_id      => '124',
            client_code => $client_code->id,
        }
    });
    $response = $user->ws_client_code($context);
    is($response->{code},           0,                  "Response: code");
    is($response->{message},        "GOOD Client Code", "Response: message");
    is($response->{client_code},    $client_code->id,   "Response: client_code unchanged");

}

1;
__DATA__
# config-file-type: JSON 1
{   
    "foo" : {
        "bar" : "baz"
    }
}


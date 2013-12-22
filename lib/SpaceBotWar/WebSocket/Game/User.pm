package SpaceBotWar::WebSocket::Game::User;

use Moose;
use MooseX::NonMoose;
extends 'SpaceBotWar::WebSocket';

# This API supports the /user route

# This is the route to the methods that interact with the user
# data, e.g. profile, password changes, etc.

# Get the users profile
#
sub ws_get_profile {
    my ($self, $context) = @_;


    return {
        code    => 0,
        message => "Success",
        profile => {
            username    => 'test_user_1',
            email       => 'me@example.com',
        },
    };
}



__PACKAGE__->meta->make_immutable;


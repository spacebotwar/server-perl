package SpaceBotWar::WebSocket::Start::User;

use Moose;

has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger( $self );
    },
);

# This API supports the /user route

# This is the route to the methods that interact with the user
# data, e.g. profile, password changes, etc.

# Get the users profile
#
sub ws_get_profile {
    my ($self, $context) = @_;

    $self->log->debug("GET_PROFILE: user [".$context->user->id."] client_code [".$context->client_code->id."]");
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


package Client;

use Moose;
use namespace::autoclean;

has 'tx' => (
    is          => 'rw',
    required    => 1,
    handles     => [qw(send)],
);

has 'id' => (
    is          => 'rw',
);

has 'name' => (
    is          => 'rw',
    isa         => 'Str',
    default     => 'bar',
);

# Return the client, as a hash
#
sub as_hash {
    my ($self) = @_;

    return {
        id      => $self->id,
        name    => $self->name,
    };
}


__PACKAGE__->meta->make_immutable;

package SpaceBotWar::Session;

use Moose;
use namespace::autoclean;
use UUID::Tiny ':std';
use SpaceBotWar;

# A unique ID for the session key
# 
has id => (
    is      => 'ro',
    default => sub {
        return create_uuid_as_string(UUID_V4);
    },
);

# Namespace to use in cache
#
has namespace => (
    is      => 'rw',
    default => 'session',
);

# The Cache object
# 
has cache => (
    is      => 'ro',
    default => sub {
        return SpaceBotWar->cache;
    },
);

# How long until the session times out due to lack of activity
#
has timeout_sec => (
    is      => 'rw',
    default => 60 * 60 * 2,
);

# Number of times the session has been extended
#
has extended => (
    is      => 'rw',
    default => 0,
);

# The ID of the user who is logged in
#
has user_id => (
    is          => 'rw',
    predicate   => 'has_user_id',
);

sub BUILD {
    my ($self) = @_;

    $self->from_hash($self->cache->get_and_deserialize($self->namespace, $self->id));
}


# Create a hash of this session
#
sub to_hash {
    my ($self) = @_;

    return {
        user_id     => $self->user_id,
        extended    => $self->extended,
    };
}

# Update the object from the hash
#
sub from_hash {
    my ($self, $hash) = @_;

    if (defined $hash and ref $hash eq 'HASH') {
        $self->user_id($hash->{user_id});
        $self->extended($hash->{extended});
    }
}


# extend the session timer
# 
sub extend {
    my ($self) = @_;

    $self->extended($self->extended + 1);
    $self->cache->set('session', $self->id, $self->to_hash, $self->timeout_sec);
}

__PACKAGE__->meta->make_immutable;


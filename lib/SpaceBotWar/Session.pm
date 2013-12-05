package SpaceBotWar::Session;

use Moose;
use namespace::autoclean;
use UUID::Tiny ':std';
use SpaceBotWar;
use Digest::MD5 qw(md5_hex);

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

# Class method. Create a new session variable
#   A session is created from a UUID (E.G. '6ba7b810-9dad-11d1-80b4-00c04fd430c8' followed by a md5
#   which we use to ensure the UUID is one created by us (and not invented by the client)
#   making it look like '6ba7b810-9dad-11d1-80b4-00c04fd430c8-0123af'
sub create_session {
    my ($class) = @_;

    my $secret  = SpaceBotWar->config->get('secret');
    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$secret), 0, 6);
    return $uuid."-".$digest;
}

# Validate a session variable
#
sub validate_session {
    my ($class, $session) = @_;

    return if not defined $session;
    my $secret  = SpaceBotWar->config->get('secret');
    my $uuid    = substr($session, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$secret), 0, 6);
    print STDERR "#######[$test] [$session]###########\n";
    return $test eq $session ? 1 : 0;
}

# Validate a session variable with confess
#
sub assert_validate_session {
    my ($class, $session) = @_;

    confess [1001, "Session is missing"] if not defined $session;
    if (not $class->validate_session($session)) {
        confess [1001, "Session is invalid!", "[$session]"];
    }
    return 1;
}






__PACKAGE__->meta->make_immutable;


package SpaceBotWar::EmailCode;

use Moose;
use namespace::autoclean;
use UUID::Tiny ':std';
use SpaceBotWar;
use Digest::MD5 qw(md5_hex);

# A unique ID for the client_code key
#
has id => (
    is      => 'ro',
    default => sub {
        return _create_id();
    },
);

# Namespace to use in cache
#
has namespace => (
    is      => 'rw',
    default => 'email_code',
);

# The Cache object
#
has cache => (
    is      => 'ro',
    default => sub {
        return SpaceBotWar->cache;
    },
);

# How long until the email_code times out
#
has timeout_sec => (
    is      => 'rw',
    default => 60 * 60 * 4,
);

# The ID of the User who requested the email code
#
has user_id => (
    is      => 'rw',
    isa     => 'Int',
);

# log4perl logger
has log => (
    is        => 'rw',
    default => sub {
        my ($self) = @_;
        return Log::Log4perl->get_logger($self);
    },
);



# Called *after* the object has been constructed
#
sub BUILD {
    my ($self,$args) = @_;

    $self->from_hash($self->cache->get_and_deserialize($self->namespace, $self->id));
}


# Create a new random id
#   Add a 'secret' so that people can't invent their own client_code
#
sub _create_id {
    my $secret  = SpaceBotWar->config->get('email_secret');
    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$secret), 0, 6);
    return $uuid."-".$digest;
}

# Automatically extend the client_code if we update any values
#
for my $func (qw(user_id)) {
    around $func => sub {
        my $orig = shift;
        my $self = shift;

        return $self->$orig() if not @_;

        my $ret = $self->$orig(@_);
        $self->extend;
        return $ret;
    };
}

# extend the client_code timer
#
sub extend {
    my ($self) = @_;

    $self->cache->set($self->namespace, $self->id, $self->to_hash, $self->timeout_sec);
}

# Create a hash of this client_code
#
sub to_hash {
    my ($self) = @_;

    return {
        user_id     => $self->user_id,
    };
}

# Update the object from a hash
#
sub from_hash {
    my ($self, $hash) = @_;

    if (defined $hash and ref $hash eq 'HASH') {
        $self->user_id($hash->{user_id});
    }
}



# Validate an email code
#
sub validate {
    my ($self) = @_;

    return if not defined $self->id;
    my $secret  = SpaceBotWar->config->get('email_secret');
    my $uuid    = substr($self->id, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$secret), 0, 6);
    $self->log->debug("test = [$test]");
    $self->log->debug("retn = [".$self->id."]");
    return $test eq $self->id ? $self : undef;
}

# Validate an email code with confess
#
sub assert_validate {
    my ($self) = @_;

    confess [1000, "Email Code is missing" ]                    if not defined $self->id;
    confess [1001, "Invalid Email Code", $self->id ]    if not $self->validate;
    return $self;
}


__PACKAGE__->meta->make_immutable;


package SpaceBotWar::ClientCode;

use Moose;
use namespace::autoclean;

use UUID::Tiny ':std';
use SpaceBotWar;
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

# A unique ID for the client_code key
# 
has id => (
    is      => 'ro',
    default => sub {
        return _create_client_code_id();
    },
);

# Namespace to use in cache
#
has namespace => (
    is      => 'rw',
    default => 'client_code',
);

# The Cache object
# 
has cache => (
    is      => 'ro',
    default => sub {
        return SpaceBotWar->cache;
    },
);

# The 'secret'
#
has secret => (
    is       => 'ro',
    default  => sub {
        return SpaceBotWar->config->get('secret');
    },
);    

# How long until the client_code times out due to lack of activity
#
has timeout_sec => (
    is      => 'rw',
    default => 60 * 60 * 2,
);

# Number of times the client_code has been extended
#
has extended => (
    is      => 'rw',
    default => 0,
);

# The ID of the user who is logged in (or previously logged in)
#
has user_id => (
    is          => 'rw',
    predicate   => 'has_user_id',
    default     => 0,
);

# A flag showing if the user is logged in or not
#
has logged_in => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);

# Automatically extend the client_code if we update any values
#
for my $func (qw(user_id logged_in)) {
    around $func => sub {
        my $orig = shift;
        my $self = shift;

        return $self->$orig() if not @_;

        #print STDERR "IN $func [$orig][$self]\n";
        #print STDERR Dumper(\@_);    
        my $ret = $self->$orig(@_);
        $self->extend;
        return $ret;
    };
}

sub BUILD {
    my ($self,$args) = @_;

    #print STDERR "IN BUILD 1: user_id=[".$self->user_id."] logged_in=[".$self->logged_in."]\n";
    $self->from_hash($self->cache->get_and_deserialize($self->namespace, $self->id));
    if (defined $args->{user_id}) {
        #print STDERR "IN BUILD user_id [".$args->{logged_in}."]\n";
        $self->user_id($args->{user_id});
    }
    if (defined $args->{logged_in}) {
        #print STDERR "IN BUILD logged_in [".$args->{logged_in}."]\n";
        $self->logged_in($args->{logged_in});
    }
    #print STDERR "IN BUILD 2: user_id=[".$self->user_id."] logged_in=[".$self->logged_in."]\n";
}


# Create a hash of this client_code
#
sub to_hash {
    my ($self) = @_;

    return {
        user_id     => $self->user_id,
        logged_in   => $self->logged_in,
        extended    => $self->extended,
    };
}

# Update the object from a hash
#
sub from_hash {
    my ($self, $hash) = @_;

    #print STDERR "FROM_HASH: ".Dumper($hash)."\n";
    if (defined $hash and ref $hash eq 'HASH') {
        $self->user_id($hash->{user_id});
        $self->extended($hash->{extended});
        $self->logged_in($hash->{logged_in});
    }
}


# extend the client_code timer
# 
sub extend {
    my ($self) = @_;

    $self->extended($self->extended + 1);
    $self->cache->set($self->namespace, $self->id, $self->to_hash, $self->timeout_sec);
}


# Class method. Create a new random client_code_id
#   Add a 'secret' so that people can't invent their own client_code
#   
sub _create_client_code_id {
    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$self->secret), 0, 6);
    return $uuid."-".$digest;
}


# Class method. Create a new client_code object
#   If an existing client_code_id is specified, then see if there is a cached object
#   Otherwise create it.
#   If no client_code_id is supplied, create one
#   
sub create_client_code {
    my ($class, $client_code_id) = @_;

    if (not ($client_code_id and $class->validate_client_code($client_code_id))) {
        $client_code_id = _create_client_code_id();
    }

    my $client_code = $class->new({
        id      => $client_code_id,
    });
    $client_code->extend;

    return $client_code;
}

# Validate a client_code variable
#
sub validate_client_code {
    my ($class, $client_code_id) = @_;

    return if not defined $client_code_id;
    my $uuid    = substr($client_code_id, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$self->secret), 0, 6);
    if ($test eq $client_code_id) {
        return $class->new({
            id      => $client_code_id,
        });
    }
    return;
}

# Validate a client_code variable with confess
#
sub assert_validate_client_code {
    my ($class, $client_code_id) = @_;

    confess [1001, "Client Code is missing"] if not defined $client_code_id;
    my $client_code = $class->validate_client_code($client_code_id);
    if (not $client_code) {
        confess [1001, "Client Code is invalid!", "[$client_code_id]"];
    }
    return $client_code;
}

__PACKAGE__->meta->make_immutable;


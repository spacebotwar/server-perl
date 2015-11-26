package SpaceBotWar::RemoteCode;

# Class to execute unsafe users code, remotely in a Jail
#

use Moose;
use namespace::autoclean;

use SpaceBotWar;
use App::EvalServer;
#use Data::Dumper;
use POE;
use POE::Filter::JSON;
use POE::Wheel::ReadWrite;
use POE::Wheel::SocketFactory;
use Socket;


# The language the code is written in.
# e.g. 'perl', 'php', 'ruby'
# although only 'perl' is currently supported
#
has 'language' => (
    is      => 'rw',
    isa     => 'Str',
);

# The actual code. This is a string containing the code to
# execute. Note, it is assumed that only one source code file
# is provided.
#
has 'code' => (
    is      => 'rw',
    isa     => 'Str',
);

# The data passed to the code. This will be inserted into the
# 'code' as a data structure.
#
has 'data' => (
    is      => 'rw',
    isa     => 'Str',
);

# The output hash of the code
#   result      The result of the evaluation
#   stdout      Everything printed to STDOUT
#   stderr      Everything printed to STDERR
#   output      The merged stdout/stderr
#   memory      The memory use (as reported by getrusage)
#   real_time   The real-time taken by the process
#   user_time   The user-time taken by the process
#   sys_time    The sys time taken by the process
#
#   error       If an error occured before the code could be evaluated
#   
#   TODO Perhaps split these into object attributes?
#
has 'output' => (
    is      => 'rw',
);

# Execute the code. Note, this is a blocking call until the
# executing code completes.
# 
sub execute {
    my ($self) = @_;

    POE::Session->create(
        object_states => [
            $self => [qw(
                _start
                connect_failed
                connected
                eval_read
                eval_error
                shutdown
            )],
        ]
    );

    $poe_kernel->run;
}

# On creation of a POE session, create a socket connection to the App Evaluation Server
# 
sub _start {
    my ($self,$heap) = @_[OBJECT,HEAP];

    my $port = $self->get_port;
    print STDERR "## PORT = [$port] HEAP=[$heap]##\n";
    $heap->{server} = App::EvalServer->new(
        port    => $port,
        timeout => 10,
#        unsafe  => 1,           # UNSAFE for now, should be safe in production!
    );

    $heap->{server}->run;

    $heap->{socket} = POE::Wheel::SocketFactory->new(
        RemoteAddress   => '127.0.0.1',             # TODO Take this from the config
        RemotePort      => $port,
        FailureEvent    => 'connect_failed',
        SuccessEvent    => 'connected',
    );
}

# The connection failed for some reason
#
sub connect_failed {
    my ($self, $kernel) = @_[OBJECT,KERNEL];

    $kernel->yield('shutdown');
}


# the connection to the App Evaluation Server has been established!
#
sub connected {
    my ($self, $socket, $heap) = @_[OBJECT, ARG0, HEAP];

    $heap->{rw} = POE::Wheel::ReadWrite->new(
        Handle      => $socket,
        Filter      => POE::Filter::JSON->new,
        InputEvent  => 'eval_read',
        ErrorEvent  => 'eval_error',
    );

    $heap->{rw}->put({
        lang    => $self->language,
        code    => $self->code,
    });
}

# Get a free port number to use
#
sub get_port {
    my $self = shift;

    my $wheel = POE::Wheel::SocketFactory->new(
        BindAddress     => '127.0.0.1',         # TODO get this from a config
        BindPort        => 0,                   # Select a free port
        SuccessEvent    => '_fake_success',     # We don't care!
        FailureEvent    => '_fake_failure',     # We don't care!
    );

    return if !$wheel;
    return unpack_sockaddr_in($wheel->getsockname) if wantarray;
    return (unpack_sockaddr_in($wheel->getsockname))[0];
}


# Read the result from the App Evaluation Server
#
sub eval_read {
    my ($self, $output, $heap) = @_[OBJECT, ARG0, HEAP];

    # Save the result somewhere!
    #
    $self->output($output);
    $heap->{success} = 1;
}


# There was an error
#
sub eval_error {
    my ($self, $heap, $kernel) = @_[OBJECT, HEAP, KERNEL];

    if ($heap->{success}) {
        # Got disconnected
    }
    else {
        # Fail, premature disconnect
    }
    $kernel->yield('shutdown');
}

# shutdown
#
sub shutdown {
    my ($self, $heap) = @_[OBJECT, HEAP];

    $heap->{server}->shutdown;
    delete $heap->{server};
    delete $heap->{rw};
    delete $heap->{socket};
}





__PACKAGE__->meta->make_immutable;


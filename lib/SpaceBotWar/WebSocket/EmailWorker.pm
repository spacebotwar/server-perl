package SpaceBotWar::WebSocket::EmailWorker;

use Moose;
extends 'SpaceBotWar::WebSocket';

use AnyEvent;
use AnyEvent::Beanstalk;
use SpaceBotWar;
use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;
use Carp;
use UUID::Tiny ':std';
use JSON;
use Try;

# This process is responsible for processing all email jobs
# which it does by taking them off the email queue and sending them
# by creating it as a WebSocket we can also monitor the queue from
# an Admin account.


has 'beanstalk' => (
    is          => 'rw',
    isa         => 'AnyEvent::Beanstalk',
    builder     => '_build_beanstalk',
    lazy        => 1,
);

# Create a default beanstalk queue
#
sub _build_beanstalk {
    my ($self) = @_;

    my $config = SpaceBotWar->config;
    my $worker = AnyEvent::Beanstalk->new(
        server      => $config->get('email_queue/server'),
        on_error    => sub {
            my ($desc) = @_;
            $self->log->error("Cannot connect to email message queue [$desc]");
        },
        on_connect  => sub {
            $self->log->info("Connection made to email message queue");
        },
    );
    return $worker;
}

# Initiate the beanstalk worker
#
sub BUILD {
    my ($self) = @_;

    $self->log->debug("BUILD EMAIL WORKER - START ###### $self");
    $self->beanstalk->reserve( $self->can('_process_job') );
}

# Process a job off the email message queue
#
sub _process_job {
    my ($job) = @_;

    my $log = Log::Log4perl->get_logger( "EmailWorker::Job" );
    $log->debug("Processing job [$job]");
    
    my $data = $job->data;
    $log->debug("Job data [$data]");
    $job->delete; 
}


# A user has joined the server
#
sub on_connect {
    my ($self, $context) = @_;

    return {
        code        => 0,
        message     => 'Welcome to Space Bot War!',
    };
}

1;

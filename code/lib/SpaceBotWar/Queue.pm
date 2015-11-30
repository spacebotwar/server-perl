package SpaceBotWar::Queue;

use MooseX::Singleton;
use Beanstalk::Client;
use Data::Dumper;

use SpaceBotWar::Queue::Job;

has '_beanstalk' => (
    is          => 'ro',
    isa         => 'Beanstalk::Client',
    lazy        => 1,
    builder     => '__build_beanstalk',
);

has 'max_timeouts' => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 1,
    default     => 10,
);

has 'max_reserves' => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 1,
    default     => 10,
);

has 'server' => (
    is          => 'ro',
    isa         => 'Str',
    lazy        => 1,
    default     => 'localhost',
);

has 'ttr' => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 1,
    default     => 120,
);

has 'debug' => (
    is          => 'ro',
    isa         => 'Int',
    lazy        => 1,
    default     => 0,
);

sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger( "Queue" );
}

sub __build_beanstalk {
    my ($self) = @_;

    $self->log->debug("beanstalk connect: [".$self->server."][".$self->ttr."][".$self->debug."]");
    my $beanstalk = Beanstalk::Client->new({
        server      => $self->server,
        ttr         => $self->ttr,
        debug       => $self->debug,
    });
    $self->log->debug("BEANSTALK: [$beanstalk]");

    return $beanstalk;
}

sub publish {
    my ($self, $queue, $payload, $options) = @_;

    my $log         = $self->log;
    $log->debug("queue [$queue] payload [".Dumper($payload)."] options [".Dumper($options)."]");

    my $beanstalk   = $self->_beanstalk;
    $queue          = $queue || 'default';
    $options        = defined $options ? $options : {},
    $beanstalk->use($queue);

    my $job = $beanstalk->put($options, $payload);
    $log->debug("JOB: [$job]");

    return SpaceBotWar::Queue::Job->new({job => $job});
}

sub peek {
    my ($self, $job_id) = @_;

    my $beanstalk = $self->_beanstalk;

    my $job = $beanstalk->peek($job_id);
    if ($job) {
        return SpaceBotWar::Queue::Job->new({job => $job});
    }
    return;
}

sub delete {
    my ($self, $job_id) = @_;

    my $beanstalk = $self->_beanstalk;

    $beanstalk->delete($job_id);
    return;
}


# DRY Principle
my $meta = __PACKAGE__->meta;

foreach my $proc (qw(peek_buried peek_ready peek_delayed)) {
    $meta->add_method($proc => sub {
        my ($self) = @_;

        my $job = $self->_beanstalk->$proc;
        if ($job) {
            return SpaceBotWar::Queue::Job->new({job => $job});
        }
        return;
    });
}

sub kick {
    my ($self, $bound) = @_;

    $bound = $bound || 1;

    my $beanstalk   = $self->_beanstalk;
    my $kicked      = $beanstalk->kick($bound);

    return $kicked;
}

sub pause_tube {
    my ($self, $tube, $seconds) = @_;

    $seconds = $seconds || 0;

    my $beanstalk   = $self->_beanstalk;
    my $ret = $beanstalk->pause_tube($tube, $seconds);
}

sub stats {
    my ($self) = @_;

    return $self->_beanstalk->stats;
}

sub stats_tube {
    my ($self, $tube) = @_;

    return $self->_beanstalk->stats_tube($tube);
}

sub list_tubes {
    my ($self) = @_;

    return $self->_beanstalk->list_tubes;
}

sub consume {
    my ($self,$tube) = @_;

    my $job;
    my $log = $self->log;
    my $beanstalk = $self->_beanstalk;
    $log->debug("beanstalk = [$beanstalk]");
    RESERVE:
    while (not $job) {
        $log->debug("wait on tube [$tube]");
        $beanstalk->watch_only($tube);
        $job = $beanstalk->reserve;

        # Defend against undef jobs (most likely due to DEADLINE_SOON)
        if (not $job) {
            $log->debug("No Job! [".$beanstalk->error."]");
            sleep 1;
            redo RESERVE;
        }
        $log->debug("Got job $job");
        my $stats = $job->stats;
        my $bury;

        if ($stats->timeouts > $self->max_timeouts) {
            $bury = "timeouts";
        }
        if ($stats->reserves > $self->max_reserves) {
            $bury = "reserves";
        }
        if ($bury) {
            $job->bury;
            undef $job;
        }
    }
    return SpaceBotWar::Queue::Job->new({job => $job});
}

__PACKAGE__->meta->make_immutable;

1;



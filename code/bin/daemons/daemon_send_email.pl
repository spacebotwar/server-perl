use 5.010;
use strict;
use feature "switch";
use lib '../../lib';
use SpaceBotWar;
use Getopt::Long;
use App::Daemon qw(daemonize );
use Data::Dumper;
use Try::Tiny;
use Log::Log4perl qw(:levels);
use SpaceBotWar::EmailCode;

# --------------------------------------------------------------------
# command line arguments:
#
my $daemonize   = 1;
our $quiet      = 1;
our $loop       = 1;

GetOptions(
    'daemonize!'    => \$daemonize,
    'quiet!'        => \$quiet,
    'loop!'         => \$loop,
);

$App::Daemon::loglevel = $quiet ? $WARN : $DEBUG;
$App::Daemon::logfile  = '../../log/daemon_send_email.log';

#chdir '../../space-bot-war/bin/cron_jobs';

my $timeout     = 60 * 60; # (one hour)
my $pid_file    = 'daemon_send_email.pid';

my $start = time;

# kill any existing processes
#
if (-f $pid_file) {
    open(PIDFILE, $pid_file);
    my $PID = <PIDFILE>;
    chomp $PID;
    if (grep /$PID/, `ps -p $PID`) {
        close (PIDFILE);
        out("Killing previous job, PID=$PID");
        kill 9, $PID;
        sleep 5;
    }
}

# --------------------------------------------------------------------
# Daemonize

if ($daemonize) {
    daemonize();
    out('Running as a daemon');
}
else {
    out('Running in the foreground');
}

my $config = SpaceBotWar->config;

my $queue = SpaceBotWar::Queue->new({
    max_timeouts    => $config->get('beanstalk/max_timeouts'),
    max_reserves    => $config->get('beanstalk/max_reserves'),
    server          => $config->get('beanstalk/server'),
    ttr             => $config->get('beanstalk/ttr'),
    debug           => $config->get('beanstalk/debug'),
});

out("queue = $queue");

# --------------------------------------------------------------------
# Main processing loop

out('Started');
# Timeout after an hour
eval {
    local $SIG{ALRM} = sub { die "alarm\n" };
    alarm $timeout;
    
    do {
        my $job     = $queue->consume('send_email');
        my $args    = $job->args;
        my $task    = $args->{task};
    
        out('job received ['.$job->id.']');
        out('payload '.Dumper($job->payload));

        my $payload = $job->payload;

        try {
            # process the job
            # TODO Cater for different types of email, but for now we just support
            # forgotten password emails
            #
            my $email_code = SpaceBotWar::EmailCode->new({
                timeout_sec => 5,
            });
            $email_code->user_id($payload->{user_id});
            out("Email code is [".$email_code->id."] user_id is [".$email_code->user_id."]");

            out("Processing done. Delete job ".$job->id);
            $job->delete;
        }
        catch {
            # bury the job, it failed
            out("Job ".$job->id." failed: $_");
            $job->bury;
        };
    } while ($loop);
};
if ($@) {
    die unless $@ eq "alarm\n"; # propagate unexpected errors
    # timed out
}

my $finish = time;
out('Finished');
out(int(($finish - $start)/60)." minutes have elapsed");
exit 0;

###############
## SUBROUTINES
###############

sub out {
    my ($message) = @_;
    my $logger = Log::Log4perl->get_logger("Daemon::SendEmail");
    $logger->info($message);
}


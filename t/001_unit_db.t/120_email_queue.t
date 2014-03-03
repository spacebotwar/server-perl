use 5.010;
use strict;
use feature "switch";
use lib '../lib';
use lib '../../lib';
use SpaceBotWar;
use Test::More;

use Data::Dumper;

my $config = SpaceBotWar->config;

my $queue = SpaceBotWar::Queue->new({
    max_timeouts    => $config->get('beanstalk/max_timeouts'),
    max_reserves    => $config->get('beanstalk/max_reserves'),
    server          => $config->get('beanstalk/server'),
    ttr             => $config->get('beanstalk/ttr'),
    debug           => $config->get('beanstalk/debug'),
});

diag("queue = $queue");

#my $job = $queue->consume('send_email');

#diag("job = $job");
ok(1);
done_testing;

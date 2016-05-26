use strict;
use warnings;
use Test::Most;
use Log::Log4perl;

use lib "lib";
use lib "t/lib";

use Redis;
use SpaceBotWar::Config;
use SpaceBotWar::Queue;
use SpaceBotWar::Redis;
use SpaceBotWar::DB;
use SpaceBotWar::SDB;

use Test::Class::Moose::Load 't/tests';
use Test::Class::Moose::Runner;


#--- Initialize singleton objects
#
# Connect to the Redis Docker image
#
my $redis = Redis->new(server => "192.168.99.100:6379");
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

SpaceBotWar::Config->initialize;

# Connect to the beanstalk Docker image
#
SpaceBotWar::Queue->initialize({
    server      => "192.168.99.100:11300",
    ttr         => 120,
    debug       => 0,
});

Log::Log4perl->init('/opt/code/etc/log4perl.conf');

my $db = SpaceBotWar::DB->connect(
    'DBI:SQLite:/opt/code/log/test.db',
);
$db->deploy({ add_drop_table => 1 });

SpaceBotWar::SDB->initialize({
    db => $db,
});

my $runner = Test::Class::Moose::Runner->new(statistics => 1, test_classes => \@ARGV);
$runner->runtests;
1;


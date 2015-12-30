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

use Test::Class::Moose::Load 't/lib';
use Test::Class::Moose::Runner;


#--- Initialize singleton objects
#
SpaceBotWar::Config->initialize({
    filename => '/opt/code/etc/spacebotwar.conf',
});

SpaceBotWar::Queue->initialize({
    server  => 'localhost:11300',
    ttr     => 120,
    debug   => 0,
});

my $redis = Redis->new(server => 'spacebotwar.com:6379');
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

Log::Log4perl->init('/opt/code/etc/log4perl.conf');

my $db = SpaceBotWar::DB->connect(
    'DBI:SQLite:/opt/code/log/test.db',
);
$db->deploy({ add_drop_table => 1 });

SpaceBotWar::SDB->initialize({
    db => $db,
});

my $runner = Test::Class::Moose::Runner->new(test_classes => \@ARGV);
$runner->runtests;
1;


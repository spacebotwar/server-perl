use strict;
use warnings;
use Test::Most;
use Log::Log4perl;

use lib "lib";

use Redis;
use SpaceBotWar::Config;
use SpaceBotWar::Queue;
use SpaceBotWar::Redis;

use Test::Class::Moose::Load 't/unit';
use Test::Class::Moose::Runner;


#--- Initialize singleton objects
#
SpaceBotWar::Config->initialize({
    filename => '/Users/icydee/sandbox/space-bot-war/spacebotwar.conf',
});

SpaceBotWar::Queue->initialize({
    server  => 'localhost:11300',
    ttr     => 120,
    debug   => 0,
});

my $redis = Redis->new(server => 'localhost:6379');
SpaceBotWar::Redis->initialize({
    redis => $redis,
});

Log::Log4perl->init('/Users/icydee/sandbox/space-bot-war/log4perl.conf');

my $runner = Test::Class::Moose::Runner->new(test_classes => \@ARGV);
$runner->runtests;
1;


use strict;
use warnings;
use Test::Most;
use Log::Log4perl;

use Test::Class::Moose::Load 't/unit';
use Test::Class::Moose::Runner;

Log::Log4perl::init('log4perl.conf');

my $runner = Test::Class::Moose::Runner->new(test_classes => \@ARGV);
$runner->runtests;
1;


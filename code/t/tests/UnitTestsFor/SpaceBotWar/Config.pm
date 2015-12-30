package UnitTestsFor::SpaceBotWar::Config;

use lib "lib";

use Test::Class::Moose;
use File::Temp qw(tempfile);
use Data::Dumper;

use SpaceBotWar::Config;

sub test_construction_foo {
    my ($self) = @_;

    my $config = SpaceBotWar::Config->instance;

    isa_ok($config, 'SpaceBotWar::Config');

    is($config->get('test/foo'), 'bar', "Can get from config");
}

1;


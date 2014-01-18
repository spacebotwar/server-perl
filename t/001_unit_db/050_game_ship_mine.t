use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Test::Exception;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::Game::Ship::Mine;
use SpaceBotWar::Game::Ship::Enemy;

my $my_ship = SpaceBotWar::Game::Ship::Mine->new({
    id          => 0,
    owner_id    => 0,
});

isa_ok($my_ship, 'SpaceBotWar::Game::Ship::Mine', "Correct class");
isa_ok($my_ship, 'SpaceBotWar::Game::Ship', "Correct super class");

my $enemy_ship = SpaceBotWar::Game::Ship::Enemy->new({
    id          => 0,
    owner_id    => 0,
});

isa_ok($enemy_ship, 'SpaceBotWar::Game::Ship::Enemy', "Correct class");
isa_ok($enemy_ship, 'SpaceBotWar::Game::Ship', "Correct super class");

# Determine what attributes should be readonly, readwrite or bare (no read or write)
# for a players own ships
#
my $mine_tests = {
    id                  => 'readonly',
    owner_id            => 'readonly',
    name                => 'readonly',
    type                => 'readonly',
    status              => 'readonly',
    health              => 'readonly',
    x                   => 'readonly',
    y                   => 'readonly',
    rotation            => 'readwrite',
    orientation         => 'readonly',
    thrust_forward      => 'readwrite',
    thrust_sideway      => 'readwrite',
    thrust_reverse      => 'readwrite',
    max_thrust_forward  => 'readonly',
    max_thrust_sideway  => 'readonly',
    max_thrust_reverse  => 'readonly',
    max_rotation        => 'readonly',
    speed               => 'readonly',
    direction           => 'readonly',
};

# Determine what attributes should be readonly, readwrite or bare (no read or write)
# for the other players ships
#
my $enemy_tests = {
    id                  => 'readonly',
    owner_id            => 'readonly',
    name                => 'readonly',
    type                => 'readonly',
    status              => 'readonly',
    health              => 'readonly',
    x                   => 'readonly',
    y                   => 'readonly',
    rotation            => 'bare',
    orientation         => 'readonly',
    thrust_forward      => 'bare',
    thrust_sideway      => 'bare',
    thrust_reverse      => 'bare',
    max_thrust_forward  => 'bare',
    max_thrust_sideway  => 'bare',
    max_thrust_reverse  => 'bare',
    max_rotation        => 'bare',
    speed               => 'readonly',
    direction           => 'readonly',
};

sub do_test {
    my ($prefix, $ship, $attribute, $testname) = @_;

    # Read tests
    if ($testname eq 'readonly' or $testname eq 'readwrite') {
        # 'read' should not give an exception
        lives_ok { $ship->$attribute } "$prefix: read [$attribute] should live";
    }
    if ($testname eq 'bare') {
        # 'read' should give an exception
        throws_ok { $ship->$attribute } qr/Cannot read from \[$attribute\]/, "$prefix: read [$attribute] should die";
    }

    # Write tests
    if ($testname eq 'readonly' or $testname eq 'bare') {
        # 'write' should give an exception
        throws_ok { $ship->$attribute(0) } qr/Cannot write to \[$attribute\]/, "$prefix: write [$attribute] should die";
    }
}

foreach my $test (keys %{$mine_tests}) {
    diag "test [$test]";
    do_test('mine', $my_ship, $test, $mine_tests->{$test});
}

foreach my $test (keys %{$enemy_tests}) {
    do_test('enemy', $enemy_ship, $test, $enemy_tests->{$test});
}

done_testing();


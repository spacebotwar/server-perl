package TestsFor::SpaceBotWar::Game::Ship;

use lib "lib";

use Test::Class::Moose;
use Test::Number::Delta within => 1e-5;

use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;


sub test_construct {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id          => 1,
        owner_id    => 2,
    });
    isa_ok($ship, 'SpaceBotWar::Game::Ship');
}

sub test_limits {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id                  => 1,
        owner_id            => 2,
        max_thrust_forward  => 100,
        max_thrust_reverse  => 10,
        max_thrust_sideway  => 5,
        max_rotation        => 2,
    });

    foreach my $thrust (0,0.1,0.001,1,10,100) {
        $ship->thrust_forward($thrust);
        is($ship->thrust_forward, $thrust, "Forward within limits: $thrust");
    }
    foreach my $thrust (-0.001, -0.1, -1, -10, -100, -1000) {
        $ship->thrust_forward($thrust);
        is($ship->thrust_forward, 0, "Forward below zero: $thrust");
    }
    foreach my $thrust (100.001, 101, 110, 1000000) {
        $ship->thrust_forward($thrust);
        is($ship->thrust_forward, 100, "Forward outside limits: $thrust");
    }

    foreach my $thrust (0,0.1,0.01,0.001,1,10) {
        $ship->thrust_reverse($thrust);
        is($ship->thrust_reverse, $thrust, "Reverse within limits: $thrust");
    }
    foreach my $thrust (-0.001, -0.1, -1, -10, -100, -1000) {
        $ship->thrust_reverse($thrust);
        is($ship->thrust_reverse, 0, "Reverse below zero: $thrust");
    }
    foreach my $thrust (10.001, 11, 110, 1000000) {
        $ship->thrust_reverse($thrust);
        is($ship->thrust_reverse, 10, "Reverse outside limits: $thrust");
    }

}

1;


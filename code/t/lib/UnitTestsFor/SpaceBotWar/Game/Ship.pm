package TestsFor::SpaceBotWar::Game::Ship;

use lib "lib";
use POSIX qw(fmod);

use Test::Class::Moose;
use Test::Number::Delta within => 1e-4;

use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;
my $pi = 3.14159;

sub test_construct {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id          => 1,
        owner_id    => 2,
    });
    isa_ok($ship, 'SpaceBotWar::Game::Ship');
}

sub test_direction {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id                  => 1,
        owner_id            => 2,
        max_thrust_forward  => 100,
        max_thrust_reverse  => 100,
        max_thrust_sideway  => 100,
        max_rotation        => 2,
    });

    my $tests = {
        0               => 0,
        $pi             => $pi,
        $pi - 0.1       => $pi - 0.1,
        0.1             => 0.1,
        $pi + 0.1       => - $pi + 0.1,
        2 * $pi         => 0,
        2 * $pi + 0.1   => 0.1,
    };

    foreach my $direction (keys %$tests) {
        # Forward direction only, direction = orientation
        $ship->thrust_forward(40);
        $ship->thrust_sideway(0);
        $ship->thrust_reverse(0);
        $ship->orientation($direction);
        delta_ok($ship->direction, $tests->{$direction}, "Going forward : $direction");

        # Reverse direction, direction = orientation + PI
        $ship->thrust_forward(0);
        $ship->thrust_reverse(30);
        $ship->orientation($direction);
        angle_ok($ship->direction, $tests->{$direction} + PI, "Going backward : $direction");
    }   

}

sub angle_ok {
    my ($got, $like, $test_name) = @_;

    my $angle = fmod($like, 2*PI);

    $angle -= 2*PI if $angle > PI;
    $angle += 2*PI if $angle < 0 - PI;

    # This is a bit of a cludge to test for numbers close to PI
    $angle = int($angle * 100000) / 100000;
    $angle = 0 - PI if $angle == PI;
    return delta_ok($got, $angle, $test_name);

}

sub test_rotation {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id                  => 1,
        owner_id            => 2,
        max_thrust_forward  => 100,
        max_thrust_reverse  => 10,
        max_thrust_sideway  => 5,
        max_rotation        => 2,
    });
    my $pi = PI;
    my $tests = {
        0       => 0,
        0.01    => 0.01,
        $pi     => $pi,
        $pi * 2 => 0,
        $pi * 4 => 0,
        $pi * 4 + 0.001 => 0.001,
    };

    is($ship->orientation, 0, "Orientation defaults to zero");

    foreach my $angle (sort keys %$tests) {
        my $result = $tests->{$angle};
        $ship->orientation($angle);
        delta_ok($ship->orientation, $result, "Orientation +ve to : $angle");
        $ship->orientation(0 - $angle);
        delta_ok($ship->orientation, 0 - $result, "Orientation -ve to : $angle");

    }
}

sub test_speed {
    my ($self) = @_;

    my $ship = SpaceBotWar::Game::Ship->new({
        id                  => 1,
        owner_id            => 2,
        max_thrust_forward  => 100,
        max_thrust_reverse  => 10,
        max_thrust_sideway  => 5,
        max_rotation        => 2,
    });

    $ship->thrust_forward(8);
    delta_ok($ship->speed, 8, "Forward speed");
    $ship->thrust_reverse(4);
    delta_ok($ship->speed, 4, "Some reverse");
    $ship->thrust_sideway(3);
    delta_ok($ship->speed, 5, "pythagorus lives");
    $ship->thrust_sideway(-3);
    delta_ok($ship->speed, 5, "reverse pythagorus");
    $ship->thrust_forward(0);
    $ship->thrust_reverse(4);
    delta_ok($ship->speed, 5, "in reverse");
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

    foreach my $thrust (0.01, 0.1, 1, 5, 0, -0.01, -0.1, -1, -5) {
        $ship->thrust_sideway($thrust);
        is($ship->thrust_sideway, $thrust, "Sideway thrust within limits: $thrust");
    }
    foreach my $thrust (5.01, 5.1, 6, 100) {
        $ship->thrust_sideway($thrust);
        is($ship->thrust_sideway, $ship->max_thrust_sideway, "Sideway outside limits +ve: $thrust");
        $ship->thrust_sideway(0 - $thrust);
        is($ship->thrust_sideway, 0 - $ship->max_thrust_sideway, "Sideway outside limits -ve : $thrust");
    }

    foreach my $rotation (0, 0.01, 0.1, 1, 2) {
        $ship->rotation($rotation);
        is($ship->rotation, $rotation, "Rotation +ve within limits: $rotation");

        $ship->rotation(0 - $rotation);
        is($ship->rotation, 0 - $rotation, "Rotation -ve within limits: $rotation");
    }

    foreach my $rotation (2.01, 2.1, 3, 300) {
        $ship->rotation($rotation);
        is($ship->rotation, $ship->max_rotation, "Rotation +ve outside limits: $rotation");
        
        $ship->rotation(0 - $rotation);
        is($ship->rotation, 0 - $ship->max_rotation, "Rotation -ve outside limits: $rotation");
    }
}

1;


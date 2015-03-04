package TestsFor::SpaceBotWar::Game::Arena;

use lib "lib";
use POSIX qw(fmod);

use Test::Class::Moose;
use Test::More;

use Test::Number::Delta within => 1e-4;

use SpaceBotWar::Game::Arena;

use constant PI => 3.14159;
my $pi = 3.14159;

sub test_construct {
    my ($self) = @_;

    my $arena = SpaceBotWar::Game::Arena->new({
    });
    isa_ok($arena, 'SpaceBotWar::Game::Arena');
    can_ok($arena, qw(ships accept_move tick));

    # Test for defaults
    my $ships = $arena->ships;
    isnt($ships, undef, "Default ships are defined");
    # Default ships should consist of 12 ships
    is(scalar(@$ships), 12, "Should be 12 ships"); 
    # Check for standard formation
    my $ship_layout = {
        1   => { x => -140, y => -240, direction => PI/4 },
        2   => { x => -200, y => -240, direction => PI/4 },
        3   => { x => -140, y => -300, direction => PI/4 },
        4   => { x => -140, y => -360, direction => PI/4 },
        5   => { x => -200, y => -300, direction => PI/4 },
        6   => { x => -260, y => -240, direction => PI/4 },
        7   => { x => 140, y => 240, direction => PI/4 + PI },
        8   => { x => 200, y => 240, direction => PI/4 + PI },
        9   => { x => 140, y => 300, direction => PI/4 + PI },
        10  => { x => 140, y => 360, direction => PI/4 + PI },
        11  => { x => 200, y => 300, direction => PI/4 + PI },
        12  => { x => 260, y => 240, direction => PI/4 + PI },
    };
    foreach my $id (1..12) {
        my $ship = $ships->[$id - 1];
        # Ship is of the correct type
        isa_ok($ship, 'SpaceBotWar::Game::Ship', "Ship $id is of the correct type");
        # Check the defaults
        my $ship_id = $ship->id;
        is($ship->x, $ship_layout->{$ship_id}{x}, "Ship no $ship_id : x position is correct");
        is($ship->y, $ship_layout->{$ship_id}{y}, "Ship no $ship_id : y position is correct");
        angle_ok($ship->direction, $ship_layout->{$ship_id}{direction}, "Ship no $ship_id : direction is correct");
        angle_ok($ship->orientation, $ship_layout->{$ship_id}{direction}, "Ship no $ship_id : orientation is correct");
        foreach my $method (qw(thrust_forward thrust_reverse thrust_sideway rotation)) {
            is($ship->$method, 0, "Ship $ship_id : $method is zero");
        }
    }
}

#--- Test the ship tick routine
#
sub test_tick {
    my ($self) = @_;

    # default ship, not moving
    my $ship = SpaceBotWar::Game::Ship->new({
        id              => 1,
        owner_id        => 1,
    });

    my $arena = SpaceBotWar::Game::Arena->new({
        ships       => [$ship],
    });
    isa_ok($arena, 'SpaceBotWar::Game::Arena');
    can_ok($arena, qw(ships accept_move tick));

    $arena->tick(5);
    is($arena->start_time, 0.5, "Start time increments");
    
    # ships with no speed should not move
    is($ship->x, 0, "Start X position");
    is($ship->y, 0, "Start Y position");
    is($ship->direction, 0, "Start direction");
    is($ship->orientation, 0, "Start orientation");

    my $tests = {
        move_x_pos  => { x => 0, y => 0, direction => 0, speed => 1, result_x => 1, result_y => 0, },
        move_x_neg  => { x => 0, y => 0, direction => PI, speed => 2, result_x => -2, result_y => 0, },
    };

    foreach my $test (sort keys %$tests) {
        my $data = $tests->{$test};
        $ship->x($data->{x});
        $ship->y($data->{y});
        $ship->direction($data->{direction});
        $ship->orientation($data->{direction});
        $ship->thrust_forward($data->{speed});
        is($ship->thrust_forward, $data->{speed}, "Correct forward thrust");
        is($ship->speed, $data->{speed}, "Correct ship speed");
        $arena->tick(10);
        is($ship->x, $data->{result_x}, "Ship test $test, x movement");
        is($ship->y, $data->{result_y}, "Ship test $test, y movement");
        is($ship->direction, $data->{direction}, "Ship test $test, direction");
        is($ship->orientation, $data->{direction}, "Ship test $test, orientation");
    }
}



# TODO: Factor this out into a standard test module. (for CPAN?)
#
sub angle_ok {
    my ($got, $like, $test_name) = @_;

    my $like_angle = fmod($like, 2*PI);

    $like_angle -= 2*PI if $like_angle > PI;
    $like_angle += 2*PI if $like_angle < 0 - PI;

    # This is a bit of a cludge to test for numbers close to PI
    $like_angle = 0 - PI if $like_angle + 0.000001 >= PI;

    my $got_angle = fmod($got, 2*PI);
    $got_angle -= 2*PI if $got_angle > PI;
    $got_angle += 2*PI if $got_angle < 0 - PI;
    $got_angle = 0 - PI if $like_angle + 0.000001 >= PI;

    return delta_ok($got_angle, $like_angle, $test_name);

}



1;


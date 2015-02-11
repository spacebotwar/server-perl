package TestsFor::SpaceBotWar::Game;

use lib "lib";

use Test::Class::Moose;
use Test::Number::Delta within => 1e-5;

use SpaceBotWar::Game;

use constant PI => 3.14159;

# All angles (in radians) should be normalized to return
# a value in the range -PI to +PI
#
sub test_normalize {
    my ($self) = @_;

    my $game = SpaceBotWar::Game->new;
    my $tests = {
        0       => 0,
        1.4     => 1.4,
        3.14	=> 3.14,
       -3.14    => -3.14,
        3.2     => -3.08318,
       -3.2     => 3.08318,
    };
    isa_ok($game, 'SpaceBotWar::Game');

    foreach my $input (sort keys %$tests) {
        foreach my $delta (0, PI*2, PI* -2, PI*100, PI* -100) {
            my $output = $game->normalize_radians($input + $delta);
            delta_ok($output, $tests->{$input}, "Normalize: $input Delta: $delta");
        }
    }

}

1;


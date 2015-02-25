package TestsFor::SpaceBotWar::Game::Arena;

use lib "lib";

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
    # Each ship should be a SBW::Ship
    foreach my $ship (@$ships) {
        isa_ok($ship, 'SpaceBotWar::Game::Ship', "Ship is of the correct type");
    }
}




1;


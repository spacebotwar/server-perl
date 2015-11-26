package SpaceBotWar::Player;

use strict;
use warnings;

# Code called by player code, intentionally not using modern OO techniques (Moose)
# since it seems to give problems running in a 'Safe' compartment :(
#
use POSIX qw(fmod);

use constant PI => 3.14159;

# constructor
#
sub new {
    my ($class, $args) = @_;

    print STDERR "### BASE LEVEL NEW\n";

    my $self = bless {
    }, $class;
    $self->initialize($args);
    return $self;
}

sub initalize {
    print STDERR "### base level initialize\n";
    return;
}


# Normalise an angle to return in the range -PI to +PI
# (this could be factored out into a module, but it would be lonely!)
#
sub normalize_radians {
    my ($self, $angle) = @_;

    my $f_angle = fmod($angle, 2*PI);

    $f_angle -= 2*PI if $f_angle > PI;
    $f_angle += 2*PI if $f_angle < 0 - PI;

    return $f_angle;
}
1;


package SpaceBotWar::Game;

use Moose;
use Data::Dumper;
#use Log::Log4perl;
use POSIX qw(fmod);

use namespace::autoclean;

use constant PI => 3.14159;

sub log {
#    my ($self, $logger) = @_;
#    return Log::Log4perl->get_logger( $logger || $self );
}

# Normalise an angle to return in the range -PI to +PI
# (this could be factored out into a module, but it would be lonely!)
#
sub normalize_radians {
    my ($self, $angle) = @_;

#    my $log = $self->log;

#    $log->debug("angle = [$angle]");
    my $f_angle = fmod($angle, 2*PI);
#    $log->debug("f_angle = [$f_angle]");

    $f_angle -= 2*PI if $f_angle > PI;
    $f_angle += 2*PI if $f_angle < 0 - PI;
#    $log->debug("return = [$f_angle]");

    return $f_angle;
}

__PACKAGE__->meta->make_immutable;

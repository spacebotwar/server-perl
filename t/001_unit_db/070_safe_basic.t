use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;
use Safe;
use Safe::Hole;


our $ship = Ship::Mine->new({});

my $compartment = Safe->new;
my $hole = Safe::Hole->new({});

$hole->wrap($ship, $compartment, '$ship');

$compartment->reval('$ship->thrust_forward(42);');
print $@ if $@;

print STDERR "RETURN thrust = ".$ship->{thrust_forward}."\n";



package Ship::Mine;
sub new { bless {}, shift(); }

sub thrust_forward {
    my ($self, $thrust) = @_;
    print STDERR "thrust = $thrust\n";
    $self->{thrust_forward} = $thrust;
}
1;



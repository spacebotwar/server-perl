package SpaceBotWar::Game::Ship::Enemy;

use Moose;
use MooseX::Privacy;

use namespace::autoclean;

extends 'SpaceBotWar::Game::Ship';



# Make some of the attributes private
# So that you can't read or write the enemy values
has ['+thrust_forward', '+thrust_reverse', '+thrust_sideway', 
    '+rotation', '+max_thrust_forward', '+max_thrust_sideway', '+max_thrust_reverse', '+max_rotation',] => (
    traits  => [qw/Protected/],
);

# Methods that we can't use in a subclass
# (can't we make them private?)
sub open_fire_absolute { die "Cannot call this method"; }
sub open_fire_relative { die "Cannot call this method"; }
sub fire_missile { die "Cannot call this method"; }
sub missile_launch { die "Cannot call this method"; }
sub missile_direction { die "Cannot call this method"; }
sub missile_reloading { die "Cannot call this method"; }

# Make some of the attributes read-only
#has ['+id', '+owner_id', '+name','+type','+status','+health','+x','+y','+orientation'] => (
#    is      => 'ro',
#);
# The above does not work...
#
for my $method ( qw(id owner_id name type status health x y orientation speed direction)) {
    before $method => sub {
        my $self = shift;
        if (@_) {
            die "Cannot write to [$method]";
        }
    };
}

# It seems a bit of a cludge doing this, I can't see how else to do it whilst retaining the benefit of 'protected' attributes.
#
sub speed {
    my ($self) = @_;

    return $self->actual_speed($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse);
}
sub direction {
    my ($self) = @_;

    return $self->actual_direction($self->thrust_forward, $self->thrust_sideway, $self->thrust_reverse, $self->orientation);
}

#__PACKAGE__->meta->make_immutable;
1;


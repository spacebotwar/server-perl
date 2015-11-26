package SpaceBotWar::Game::Arena;

# An arena contaning many ships

use Moose;
use namespace::autoclean;
use Data::Dumper;
use Math::Round;

use SpaceBotWar::Game::Ship;

use constant PI => 3.14159;

extends "SpaceBotWar::Game";

# An array of all the ships in the Arena
#
has ships => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Ship]',
    lazy    => 1,
    builder => '_build_ships',
);

# An array of all the missiles in the Arena
#
has missiles => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Game::Missile]',
    default => sub { [] },
);

# This size (radius) of the arena (in pixels)
has radius  => (
    is      => 'rw',
    isa     => 'Int',
    default => 1000,
);

# The 'time' (in seconds) from when the Tournament was started
# 
has start_time => (
    is      => 'rw',
    isa     => 'Num',
    default => 0,
);
# Competitors
#
has competitors => (
    is      => 'rw',
);

# Arena Status
#
has status => (
    is      => 'rw',
    isa     => 'Str',
    default => 'starting',
);

sub log {
    my ($self) = @_;
    return Log::Log4perl->get_logger( "SpaceBotWar::Game::Arena");
}

# An arena is assumed to be a circle of radius $self->radius
# with the x,y origin in the centre.


# Create an Arena with standard ships
#
sub BUILD {
    my ($self) = @_;

#    $self->_initialize;
}

sub _build_ships {
    my ($self) = @_;

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

    my @ships;
    foreach my $ship_id (sort keys %$ship_layout) {
        my $ship_ref = $ship_layout->{$ship_id};
        my $ship = SpaceBotWar::Game::Ship->new({
            id              => $ship_id,
            owner_id        => int(($ship_id - 1) / 6) + 1,
            type            => 'ship',
            x               => $ship_ref->{x},
            y               => $ship_ref->{y},
            thrust_forward  => 0,
            thrust_sideway  => 0,
            thrust_reverse  => 0,
            orientation     => $ship_ref->{direction},
            rotation        => 0,
            owner_id    => 1,
        });
        push @ships, $ship;
    }
    $self->ships(\@ships);
}

# Set initial ship positions.
sub _initialize {
    my ($self) = @_;
    
    $self->start_time(-1);
    $self->log->debug("######status = starting at [".$self->start_time."] ############");
    $self->status('starting');
}

after 'status' => sub {
    my ($self, $val) = @_;

    if (defined $val) {
        if ($val eq 'init') {
            $self->_initialize;            
        }
    }
};

# Accept a players move
#   thrust_forward
#   thrust_sideway
#   thrust_reverse
#   rotation
sub accept_move {
    my ($self, $owner_id, $data) = @_;

#    $self->log->info("ACCEPT MOVE: ".Dumper($data));
    if ($data->{ships}) {
        foreach my $ship_data (@{$data->{ships}}) {

            my ($ship) = grep {$_->id == $ship_data->{ship_id}} @{$self->{ships}};
            confess [1000, "Cannot find ship with id [".$ship_data->{id}."]" ] if not defined $ship;
            confess [1000, "Can only control your own ships! [".$ship_data->{id}."]" ] if $ship->owner_id != $owner_id;
            $ship->thrust_forward($ship_data->{thrust_forward});
            $ship->thrust_reverse($ship_data->{thrust_reverse});
            $ship->thrust_sideway($ship_data->{thrust_sideway});
            $ship->rotation($ship_data->{rotation});
        }
    }
}


# Update the arena by $duration (10ths of a second)
#   most likely 'duration' will be 5 (half a second)
#
sub tick {
    my ($self, $duration) = @_;

    my $log = $self->log;
    $log->debug("TICK");
    my $duration_millisec = $duration * 100;
    $self->start_time($self->start_time + $duration / 10);

    if ($self->status eq 'starting' and $self->start_time > 0) {
        $self->status('running');
    }

    # In practice, at the start of each tick, we give the current position of all
    # ships and the thrust and rotation (as we currently know it)
    #
    # During the tick each side will only be informed of the position, direction
    # and speed of the opponent based on the information from the *start* of the
    # tick.
    #
    # At any time during the tick, a player may send in changes to their fleet to
    # change the thrust, rotation etc. and this will be used to compute the final
    # position at the *end* of the tick (i.e. the start of the next tick).
    # 
    # However, to reduce the issue of lag affecting a players move, the calculation
    # of the final position of each ship will be performed 'as-if' the changes
    # had been received at the *start* of the tick.
    #
    # In practice, this means that each player will not have full information 
    # about where the opponent is, but this is as it should be...
    #
    # For this reason, we can't display the path each ship takes until the end
    # of each tick (when each players moves are known) so the browser display
    # of the movements must lag by up to 1 tick behind the actual game play.
    #
    # This should have minimal affect on the game play, except when (if) we allow
    # manual input (auto off) where there will be 1 tick lag.
    # 

    my $radius_squared = $self->radius * $self->radius;
    my $max_missile_id = 0;
    foreach my $missile (@{$self->missiles}) {
        $max_missile_id = $missile->id if $missile->id > $max_missile_id;
        my $distance = $missile->speed * $duration_millisec / 1000;
        my $delta_x = $distance * cos($missile->direction);
        my $delta_y = $distance * sin($missile->direction);
        $missile->end_x(int($missile->x + $delta_x));
        $missile->end_y(int($missile->y + $delta_y));
        # TODO we need to take into account the max range of the missile.
    }

    # Calculate the end position for each ship first
    #
    foreach my $ship (@{$self->ships}) {
        # No longer check for limits here, all done in the Ship module!
        # Calculate the final position based on thrust and direction
        my $distance = $ship->speed * $duration_millisec / 1000;
        $self->log->debug("Ship distance = [$distance]");
        my $delta_x = $distance * cos($ship->direction);
        my $delta_y = $distance * sin($ship->direction);
        $self->log->debug("Delta x = [$delta_x] delta y = [$delta_y]");
        
        my $end_x = round($ship->x + $delta_x);
        my $end_y = round($ship->y + $delta_y);
    
        # check for limits.
        if ($end_x * $end_x + $end_y * $end_y > $radius_squared) {
            # Then outside the bounds of the arena, bring it back.
            my $angle = atan2($end_y, $end_x);
            $end_x = round(cos($angle) * 1000);
            $end_y = round(sin($angle) * 1000);
        }
        $ship->x($end_x);
        $ship->y($end_y);

        # we can also check for the firing of the missiles
#        my $missile = $ship->open_fire($max_missile_id + 1);
#        if ($missile) {
#            push @{$self->missiles}, $missile;
#            $max_missile_id++;
#        }
    }

    # Now check for collisions (can we not merge these two loops together?)
    # 
    foreach my $ship (@{$self->ships}) {
        $self->log->debug("ship id ".$ship->id);        
        # Check for ship-to-ship collisions, in which case come to an early halt
        SHIP:
        foreach my $other_ship (@{$self->ships}) {
            next SHIP if $ship == $other_ship;
            # Check for intersection of two ships
            $self->intersect_ship_ship($ship, $other_ship);

        }
        # Check for hits by missiles. In which case cause damage
        # This is basically the intersection of a line with a circle.
        MISSILE:
        foreach my $missile (@{$self->missiles}) {
            if ($self->intersect_missile_ship($missile, $ship, 20)) {
                # missile causes damage to ship
            }
        }

        # angle of rotation over the tick.
        my $angle_rad = $ship->rotation * $duration_millisec / 1000;
        $ship->orientation($ship->orientation+$angle_rad);
    }
}


# Check for the intersection of two ships. If they intersect, then move them apart so they don't touch
#
sub intersect_ship_ship {
    my ($self, $ship, $other_ship) = @_;

    my $log = $self->log;
    my $ship_dia = 60;
    my $ship_dia_squared = $ship_dia * $ship_dia;
    $log->debug("ship compare ".$ship->id." with ".$other_ship->id);
    my $dx = $ship->x - $other_ship->x;
    my $dy = $ship->y - $other_ship->y;

    my $apart_squared = $dy * $dy + $dx * $dx;
    $log->debug("Distance apart = [$apart_squared][$ship_dia_squared]");
    if ($apart_squared < $ship_dia_squared) {
        # For now, simplest solution is to move the ship away from the
        # one it is closest to
        # 'apart' is the distance they have to be moved apart by
        my $apart = $ship_dia * (1 - sqrt($apart_squared) / $ship_dia);
        $log->debug("Apart = $apart");

        # 'angle' defines the axis they have to be moved apart on
        my $angle = atan2($dy, $dx);
        $log->debug("Angle = $angle");

        # Move the ship apart from each other by half the apart_fraction on the axis between them
        my $hdx = cos($angle) * $apart / 2;
        my $hdy = sin($angle) * $apart / 2;
        $log->debug("hdx = $hdx, hdy = $hdy");

        $ship->x($ship->x + $hdx);
        $ship->y($ship->y + $hdy);
        $other_ship->x($other_ship->x - $hdx);
        $other_ship->y($other_ship->y - $hdy);
    }
}


# Check for the intersection of the missile and the ship
#   returns 'damage' as a number between 0 and 1
#
sub intersect_missile_ship {
    my ($self, $missile, $ship, $r) = @_;

    # equation taken from http://mathworld.wolfram.com/Circle-LineIntersection.html
    # Note, circle is assumed to be at (0,0) so we need to take this into account.
    # Note, for the purpose of this test, the ship is assumed to be static (which it will be,
    # relative to the speed of the missile).
    #
    my $x1  = $missile->x - $ship->x;
    my $x2  = $missile->end_x - $ship->x;
    my $y1  = $missile->y = $ship->y;
    my $y2  = $missile->end_y - $ship->y;

    my $dx  = $x2 - $x1;
    my $dy  = $y2 - $y1;
    my $dr  = sqrt($dx * $dx  + $dy * $dy);
    my $d   = ($x1 * $y2) - ($x2 * $y1);

    # Do they intersect?
    my $drs = $dr * $dr;
    my $dis = $r * $r * $drs - $d * $d;
    if ($dis <= 0) {
        # Note, tangents ($dis == 0) are ignored
        # as are total misses
        return 0;
    }
    # Yes, they intersect. Determine the chord size to estimate the damage.
    my $dis_root = sqrt($dis);
    my $sgn = $dy < 0 ? -1 : 1;
    my $dya = abs($dy);
    my $xa  = $d * $dy - $sgn * $dx * $dis_root

}

# Create hash dependent upon state
#
sub to_hash {
    my ($self) = @_;

    if ($self->status eq 'running') {
        return $self->dynamic_to_hash;
    }
    return $self->all_to_hash;
}


# Create a hash representation of the changing data in the object
# Omit static information that can be read once, and cached, in
# order to reduce the size of the frequent data.
#
sub dynamic_to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->dynamic_to_hash;
    }
    return {
        status      => $self->status,
        time        => $self->start_time,
        ships       => \@ships_ref,
        missiles    => [],
    };
}

# Everything about the arena, cache the static bits
# Ideally send this once to each client at the start.
#
sub all_to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->all_to_hash;
    }
    my @missiles_ref;
    foreach my $missile (@{$self->missiles}) {
        push @missiles_ref, $missile->all_to_hash;
    }
    return {
        status      => $self->status,
        radius      => $self->radius,
        time        => $self->start_time,
        ships       => \@ships_ref,
        missiles    => \@missiles_ref,
    };
}

__PACKAGE__->meta->make_immutable;



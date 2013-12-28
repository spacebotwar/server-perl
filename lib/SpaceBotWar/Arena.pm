package SpaceBotWar::Arena;

# An arena contaning many ships

use Moose;
use SpaceBotWar::Ship;
use namespace::autoclean;
use Data::Dumper;

use constant PI => 3.14159;

# An array of all the ships in the Arena
#
has 'ships' => (
    is      => 'rw',
    isa     => 'ArrayRef[SpaceBotWar::Ship]',
    default => sub { [] },
);
# The width of the arena (in pixels)
#
has 'width' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);
# The height of the arena (in pixels)
#
has 'height' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);
# The 'time' (in seconds) from when the Tournament was started
# 
has 'start_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
has 'end_time' => (
    is      => 'rw',
    isa     => 'Int',
    default => -1,
);
# The duration (in milliseconds) from each calculation
#
has 'duration' => (
    is      => 'rw',
    isa     => 'Int',
    default => 500,
);
# Player 'A'
#
has 'player_a' => (
    is      => 'rw',
    default => 0,
);
# Player 'B'
#
has 'player_b' => (
    is      => 'rw',
    default => 0,
);
# Arena Status
#
has 'status' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'starting',
);

has 'app' => (
    is      => 'rw',
);

# Create an Arena with random ships
#
sub BUILD {
    my ($self) = @_;

    $self->initiate;
}

# Set initial ship positions.
sub initiate {
    my ($self) = @_;
    
    my $ship_layout = {
       
        1   => { x => 150, y => 150, direction => PI/4 },
        2   => { x => 100, y => 150, direction => PI/4 },
        3   => { x => 150, y => 100, direction => PI/4 },
        4   => { x => 350, y => 350, direction => PI/4 + PI },
        5   => { x => 400, y => 350, direction => PI/4 + PI },
        6   => { x => 350, y => 400, direction => PI/4 + PI },
    };

    my @ships;
    foreach my $ship_id (sort keys %$ship_layout) {
        my $ship_ref = $ship_layout->{$ship_id};

        my $ship = SpaceBotWar::Ship->new({
            id              => $ship_id,
            owner_id        => int(($ship_id - 1) / 3) + 1,
            type            => 'ship',
            x               => $ship_ref->{x},
            y               => $ship_ref->{y},
            thrust_forward  => 0,
            orientation     => $ship_ref->{direction},
            rotation        => $ship_ref->{direction},
        });
        push @ships, $ship;
    }
    $self->ships(\@ships);
    $self->start_time(-1);
    $self->end_time(-1);


    my $ua = $self->app->ua;
    $ua->websocket($self->app->config->{ws_server}.'?player=A' => sub {
        my ($ua, $tx) = @_;

        $self->player_a($tx);

        $self->player_a->on(message => sub {
            my ($this, $json_msg) = @_;

            $self->app->log->debug("MESSAGE: to player A");
            my $json = Mojo::JSON->new;
            my $msg = $json->decode($json_msg);
            if ($json->error) {
                $self->app->log->debug("JSON Error [".$json->error."]");
                return;
            }
            return unless $msg;
            my $type = $msg->{type};

            if (not $type) {
                $self->app->log->debug("JSON Error [No type]");
                return;
            }
            if (not $self->can("msg_$type")) {
                $self->app->log->debug("No method for type [$type]");
                return;
            }
            $type = "msg_$type";
            # Call the 'method' specifed in the 'type'
            $self->$type($msg->{content});
        });

        $self->player_a->on(finish => sub {
            $self->app->log->debug("FINISH: player a");
        });
    });

    $ua->websocket($self->app->config->{ws_server}.'?player=B' => sub {
        my ($ua, $tx) = @_;

        $self->player_b($tx);

        $self->player_b->on(message => sub {
            my ($this, $json_msg) = @_;

            $self->app->log->debug("MESSAGE: to player B");
            my $json = Mojo::JSON->new;
            my $msg = $json->decode($json_msg);
            if ($json->error) {
                $self->app->log->debug("JSON Error [".$json->error."]");
                return;
            }
            return unless $msg;
            my $type = $msg->{type};

            if (not $type) {
                $self->app->log->debug("JSON Error [No type]");
                return;
            }
            if (not $self->can("msg_$type")) {
                $self->app->log->debug("No method for type [$type]");
                return;
            }
            $type = "msg_$type";
            # Call the 'method' specifed in the 'type'
            $self->$type($msg->{content});
        });

        $self->player_b->on(finish => sub {
            $self->app->log->debug("FINISH: player b");
        });
    });
}

before 'status' => sub {
    my ($self, $val) = @_;

    if (defined $val) {
        if ($val eq 'init') {
            $self->initiate;            
        }
    }
};


# Accept a players move
#
sub msg_ships_command {
    my ($self, $content) = @_;

    $self->app->log->debug("MSG_SHIPS_COMMAND");

    foreach my $ship_ref (@{$content->{ships}}) {
        my $id = $ship_ref->{id};
        my ($ship) = grep {$_->id == $id} @{$self->ships};
        if ($ship) {
            $ship->thrust_forward($ship_ref->{thrust_forward});
            $ship->thrust_sideway($ship_ref->{thrust_sideway});
            $ship->thrust_reverse($ship_ref->{thrust_reverse});
            $ship->rotation($ship_ref->{rotation});
        }
    }
}


# Update the arena by $duration (10ths of a second)
#
sub tick {
    my ($self, $duration) = @_;

    my $duration_millisec = $duration * 100;
    if ($self->start_time < 0) {
        # then this is the first time.
        $self->start_time(0);
        $self->end_time($duration_millisec);
    }
    else {
        $self->start_time($self->start_time + $duration_millisec);
        $self->end_time($self->end_time + $duration_millisec);
    }
    # In practice, on each tick, we give the current actual position of all
    # ships and the thrust and rotation (as we currently know it)
    #
    # Up until the next tick, each ship's new thrust and rotation will be received
    # from each player and this will be used to compute the actual position for
    # the next tick.
    #
    # The competing programs will only know the predicted thrust and rotation for
    # the opposing fleet, not what will happen during the tick (e.g. full forward to
    # full reverse) so the predictions will often be 'wrong'.
    #
    # For this reason we can't use the predicted value to display the game in the
    # browser, we have to use the actual values. This means the browser display
    # has to lag by 1 tick behind the actual game play.
    #
    # We will have to look at what this means when players are playing 'manually'.
    # 
    #
    # So, as mentioned above. This code currently assumes that the thrust and rotation
    # were received during the previous tick period, only to be acted upon now 'as if'
    # the command were received at the start of the previous tick period.
    # 

    # We should do this with status changes
    if ($self->start_time < 5000) {
        # during the first 10 seconds, we don't allow ship movement
    }
    elsif ($self->start_time > 30000) {
        $self->status('init');
    }
    else {
        # This is where the server interprets the player requests and adjusts them
        # to ensure they do not break game rules
        #
        foreach my $ship (@{$self->ships}) {
            # Safety net
            $ship->thrust_forward($ship->max_thrust_forward) if $ship->thrust_forward > $ship->max_thrust_forward;
            $ship->thrust_sideway($ship->max_thrust_sideway) if $ship->thrust_sideway > $ship->max_thrust_sideway;
            $ship->thrust_reverse($ship->max_thrust_reverse) if $ship->thrust_reverse > $ship->max_thrust_reverse;
            $ship->rotation($ship->max_rotation) if $ship->rotation > $ship->max_rotation;
            $ship->rotation(0-$ship->max_rotation) if $ship->rotation < 0-$ship->max_rotation;
    
            # Calculate the final position based on thrust and direction
            my $distance = $ship->speed * $duration_millisec / 1000;
            my $delta_x = $distance * cos($ship->direction);
            my $delta_y = $distance * sin($ship->direction);
            my $end_x = int($ship->x + $delta_x);
            my $end_y = int($ship->y + $delta_y);
    
            # check for limits.
            $end_x = $self->width   if $end_x > $self->width;
            $end_x = 0              if $end_x < 0;
            $end_y = $self->height  if $end_y > $self->height;
            $end_y = 0              if $end_y < 0;
    
            # Check for collisions, in which case come to an early halt
    
            # Check for hits by missiles. In which case cause damage
    
            $ship->x($end_x);
            $ship->y($end_y);
    
            # angle of rotation over the tick.
            my $angle_rad = $ship->rotation * $duration_millisec / 1000;
            $ship->orientation($ship->orientation+$angle_rad);
        }
        #
        # Send the current position to the players
        #
        if ($self->player_a) {
            my $json = {
                type    => 'ship_update',
                content => $self->to_hash,
            };
            $json->{content}{script} = 'A';
            $json->{content}{owner_id} = 1;
            $json =  Mojo::JSON->new->encode($json);
            $self->player_a->send($json);
        }
        if ($self->player_b) {
            my $json = {
                type    => 'ship_update',
                content => $self->to_hash,
            };
            $json->{content}{script} = 'B';
            $json->{content}{owner_id} = 2;
            $json =  Mojo::JSON->new->encode($json);
            $self->player_b->send($json);
        }
    }
}

# Create a hash representation of the object
#
sub to_hash {
    my ($self) = @_;

    my @ships_ref;
    foreach my $ship (@{$self->ships}) {
        push @ships_ref, $ship->to_hash;
    }
    return {
        width   => $self->width,
        height  => $self->height,
        time    => $self->start_time,
        ships   => \@ships_ref,
    };
}

__PACKAGE__->meta->make_immutable;



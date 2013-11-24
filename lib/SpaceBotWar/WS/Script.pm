package SpaceBotWar::WS::Script;

use Moose;
use Mojo::IOLoop;
use Data::Dumper;

use namespace::autoclean;

extends "SpaceBotWar::WS";

# This class is a web socket that performs the running of scripts.
use constant PI => 3.14159;

# A message to indicate the current status of a game
#
sub msg_ship_update {
    my ($self, $client, $data) = @_;

    $self->log->debug("WS:Script. got here [$self]");

    my $ship_ref        = $data->{ships};
    my $arena_width     = $data->{width};
    my $arena_height    = $data->{height};
    my $duration_millisec   = 500;

    my $commands;

    # Demo 'random walk' ship movement
    # 
    SHIP:
    foreach my $ship (@{$ship_ref}) {
        next SHIP if $ship->{owner_id} != 1;

        my ($rotation, $thrust_forward, $thrust_sideway, $thrust_reverse) = (0,0,0,0);

        my $start_x = $ship->{x};
        my $start_y = $ship->{y};
        my $end_x = $start_x;
        my $end_y = $start_y;

        my $start_orientation = $ship->{orientation};

        # Move the required distance
        my $distance = $ship->{speed} * $duration_millisec / 1000;
        my $delta_x = $distance * cos($ship->{direction});
        my $delta_y = $distance * sin($ship->{direction});
        $end_x = int($start_x + $delta_x);
        $end_y = int($start_y + $delta_y);

        my $on_edge = 0;
        if ($start_x > $arena_width - 50 and ($ship->{orientation} < PI/2 or $ship->{orientation} > 3*PI/2)) {
            $on_edge = 1;
        }
        if ($start_x < 50 and $ship->{orientation} > PI/2 and $ship->{orientation} < 3*PI/2) {
            $on_edge = 1;
        }
        if ($start_y > $arena_height - 50 and $ship->{orientation} < PI) {
            $on_edge = 1;
        }
        if ($start_y < 50 and $ship->{orientation} > PI) {
            $on_edge = 1;
        }
        if ($on_edge) {
            $thrust_forward = 0;
        }
        else {
            $thrust_forward = $ship->{max_thrust_forward};
        }

        my $delta_rotation;
        if ($on_edge) {
            $delta_rotation = $ship->{id} % 2 ? PI/8 : 0 - PI/8;
        }
        else {
           $delta_rotation = rand(PI/2) - PI/4;
        }
        my $end_orientation = $ship->{orientation} + $delta_rotation;

        $rotation = ($end_orientation - $start_orientation) / ($duration_millisec / 1000);

        # Set the values
        my $command = {
            id              => $ship->{id},
            rotation        => $rotation,
            thrust_forward  => $thrust_forward,
            thrust_sideway  => $thrust_sideway,
            thrust_reverse  => $thrust_reverse,
        };
        push @$commands, $command;
    }
    my $msg = {
        type    => 'ships_command',
        content => {
            nonce       => 'foo',
            ships       => \@$commands,
        },
    };

    $msg = Mojo::JSON->new->encode($msg);
    $self->log->debug("MESSAGE: $msg");

    $client->send($msg);
}

__PACKAGE__->meta->make_immutable;

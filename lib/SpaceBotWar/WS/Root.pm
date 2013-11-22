package SpaceBotWar::WS::Root;

use Moose;
use Mojo::IOLoop;
use Data::Dumper;
use SpaceBotWar::Room;
use SpaceBotWar::Arena;

use namespace::autoclean;

extends "SpaceBotWar::WS";

# This class controls all Games that are currently running
# A game takes place in a 'room' which contains an 'arena'
# The Room may have a number of clients that are either registered
# to 'observe' the game. There must also be two 'opponents' 
# registered with the room. The Opponents are the clients that 
# supply the instructions to the server.

has 'rooms' => (
    is          => 'rw',
    isa         => 'HashRef[SpaceBotWar::Room]',
    default     => sub { {} },
);

sub BUILD {
    my ($self) = @_;

    # every half second, update the room states (compute the future state of the ships)
    #
    Mojo::IOLoop->singleton->recurring(0.5 => sub {
        foreach my $room_id (keys %{$self->rooms}) {
            my $room = $self->rooms->{$room_id};
            $self->log->debug("ROOM - $room_id [$room]");

            # 5/10ths of a second
            $room->tick(5);

            # Send the room status to each of the subscribed clients
            #
            my $json = $self->prepare_json({
                type    => 'room_data',
                content => $room->to_hash,
            });
            $self->log->debug("OUTPUT : $json");

            # Broadcast the room state to all clients.
            $room->for_all_subscribers( sub {
                my $client = shift;
                $client->send($json);
            });

            # TODO When the game in the room has finished. Close
            # the room.
        }
    });
}

# A message to start a new tournament in a room
#
sub msg_start {
    my ($self, $client, $data) = @_;

    my $room_number = $data->{number};
    my $player_1    = $data->{player_1};
    my $player_2    = $data->{player_2};
    my $secret      = $data->{secret};

    my $arena = SpaceBotWar::Arena->new({
        duration    => 600,
        max_ships   => 6,
    });
    # If we were to just create a new room, then
    # all the existing clients would be removed.
    # This may or may not be a good thing
    #
    if (defined $self->rooms->{$room_number}) {
        $self->rooms->arena($arena);
    }
    else {
        my $room = SpaceBotWar::Room->new({
            id          => $room_number,
            arena       => $arena,
        });
        $self->rooms->{$room_number} = $room;
    }
}

# Remove a client from all currently subscribed rooms
#
sub unsub_client {
    my ($self, $client) = @_;

    # Remove the client from all subscribed rooms
    my $rooms = $self->rooms;
    foreach my $room_id (keys %$rooms ) {
        $rooms->{$room_id}->un_subscribe_client($client);
    }
}

# When the client is done, unsubscribe from all rooms
# 
after 'finish' => sub {
    my ($self, $client) = @_;

    $self->unsub_client($client);   
};





# A Data Message 'room' asking for a client to register in a room
#
sub msg_room {
    my ($self, $client, $data) = @_;

    my $room_number = $data->{number};
    my $player = '';    
    if ($data->{player}) {
        $player = $data->{player};
    }

    my $room = $self->rooms->{$room_number};
    if (not defined $room) {
        # Create a 'room' containing an Arena 
        #
        my $arena = SpaceBotWar::Arena->new({
            duration    => 500,
            max_ships   => $room_number,
        });
        $room = SpaceBotWar::Room->new({
            id          => $room_number,
            arena       => $arena,
        });
        $self->rooms->{$room_number} = $room;
    }
    # If the client is not yet registered with the room
    # 
    if (not $room->has_client($client)) {
        # unsubscribe the client from all (other) rooms
        $self->unsub_client($client);

        # Subscribe the client to this room
        $room->subscribe_client($client);
    }
}


__PACKAGE__->meta->make_immutable;

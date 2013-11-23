package SpaceBotWar::WS::ScriptRunner;

use Moose;
use Mojo::IOLoop;
use Data::Dumper;
use SpaceBotWar::Room;
use SpaceBotWar::Arena;

use namespace::autoclean;

extends "SpaceBotWar::WS";

# This class runs scripts. That is program files that control
# a fleet of ships.
# 

has 'scripts' => (
    is          => 'rw',
    isa         => 'HashRef[SpaceBotWar::Script]',
    default     => sub { {} },
);

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
sub msg_script {
    my ($self, $client, $data) = @_;

    my $room_number = $data->{number};
}


__PACKAGE__->meta->make_immutable;

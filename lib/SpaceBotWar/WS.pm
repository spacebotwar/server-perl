package SpaceBotWar::WS;

use Moose;
use Mojo::JSON;

use namespace::autoclean;

has 'log' => (
    is          => 'rw',
    default     => sub { sub {} },
);

has 'app' => (
    is          => 'rw',
);

has 'clients' => (
    is          => 'rw',
    isa         => 'HashRef[SpaceBotWar::Client]',
    default     => sub { {} },
);

# Prepare a JSON message for transmission #
sub prepare_json {
    my ($self, $args) = @_;
    
    my $msg = {
        type    => $args->{type},
        content => $args->{content},
    };
    return Mojo::JSON->new->encode($msg);
}

# Send a prepared JSON message to one client
#
sub send_json_to_client {
    my ($self, $json, $client) = @_;

    $client->send($json);
}

# Send a message to everyone, (but can 'exclude' oneself)
#
sub broadcast {
    my ($self, $args) = @_;

    my $json = $self->prepare_json($args);

    my $exclude = $args->{exclude};

    CLIENT:
    foreach my $cid (keys %{$self->clients}) {
        my $client = $self->clients->{$cid};
        next CLIENT if $exclude and $exclude == $client;

        $client->send($json);
    }
}

sub add_client {
    my ($self, $connection, $client) = @_;

    $self->clients->{$client->id} = $client;

    $self->log->debug('Added a new client. Notify all other clients');

#    $self->broadcast({
#        type    => 'new_client',
#        content => $client->as_hash,
#        exclude => $client,
#    });

    # In the event of a message
    $connection->on(message => 
        sub {
            my ($this, $json_msg) = @_;

            my $json = Mojo::JSON->new;
            $self->log->debug("Message [$json_msg] received.");
            my $msg = $json->decode($json_msg);
            if ($json->error) {
                $self->log->debug("JSON Error [".$json->error."]");
                return;
            }
            return unless $msg;
            my $type = $msg->{type};
            if (not $type) {
                $self->log->debug("JSON Error [No type]");
                return;
            }
            if (not $self->can("msg_$type")) {
                $self->log->debug("No method for type [$type]");
                return;
            }
            $type = "msg_$type";
            # Call the 'method' specifed in the 'type'
            $self->$type($client, $msg->{content});
        }
    );

    # In the event of a finish
    $connection->on(finish =>
        sub {
            $self->finish($client);
        }
    );
}

sub finish {
    my ($self, $client) = @_;

    $self->broadcast({
        type    => 'old_client',
        content => $client->as_hash,
        exclude => $client,
    });
    delete $self->clients->{$client->id};
    $self->log->debug("Client [".$client->id."] disconnected.");
}


__PACKAGE__->meta->make_immutable;

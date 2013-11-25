package SpaceBotWar::Command::deploy;
use Mojo::Base 'Mojolicious::Command';

use DBIx::Class::DeploymentHandler;

sub run {
    my $self = shift;

    my $command = shift || 'deploy';
    my $method = $self->can($command) or die "No command: $command\n";

    $self->$method();
}

sub deploy {
    my $self = shift;

    my $db = $self->app->db;
    $db->deploy;
}

1;


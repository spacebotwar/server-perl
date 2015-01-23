package TestsFor::SpaceBotWar::WebSocket::User::Fixtures;

use Moose;
extends 'DBIx::Class::EasyFixture';
use namespace::autoclean;

my %definitions = (
    user_albert => {
        new => 'User',
        using => {
            username	=> 'bert',
            password    => '{SSHA}KnIrp466EYjf16NptDR9bnhjCI5z6D14', # this is encrypted 'secret'
            email       => 'bert@example.com',
        },
    }
);

sub get_definition {
    my ($self, $name) = @_;

    return $definitions{$name};
}

sub all_fixture_names { return keys %definitions };

__PACKAGE__->meta->make_immutable;
1;


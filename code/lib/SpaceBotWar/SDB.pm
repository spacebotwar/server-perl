package SpaceBotWar::SDB;

use MooseX::Singleton;
use namespace::autoclean;

has db => (
    is          => 'rw',
    required    => 1,
    isa         => 'SpaceBotWar::DB',
    handles     => [qw(resultset)],
);

__PACKAGE__->meta->make_immutable;


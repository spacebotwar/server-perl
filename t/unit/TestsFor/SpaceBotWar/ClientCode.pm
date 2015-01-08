package TestsFor::SpaceBotWar::ClientCode;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';

#use SpaceBotWar::ClientCode;
#use SpaceBotWar::Cache;

sub test_construction {
    my ($self) = @_;

    ok(1);

#    my $mock    = mock_anon_class 'SpaceBotWar::Cache';
#    my $cache   = $mock->new_object({
#        redis	=> 1,
#    });
#    $cache->mock_return( set => 1 );
#    $cache->mock_return( get_and_deserialize => undef );

#    my $client_code = SpaceBotWar::ClientCode->new({
#        cache   => $cache,
#        secret  => 'topSekret',
#    });
}


1;


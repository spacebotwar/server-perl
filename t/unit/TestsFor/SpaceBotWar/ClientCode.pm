package TestsFor::SpaceBotWar::ClientCode;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';

use SpaceBotWar::ClientCode;
use SpaceBotWar::Cache;

sub test_construction {
    my ($self) = @_;

    ok(1);

    my $mock    = mock_anon_class 'SpaceBotWar::Cache';
    my $cache   = $mock->new_object({
        redis	=> 1,
    });
    $cache->mock_return( set => 1 );
    $cache->mock_return( get_and_deserialize => undef );

    my $client_code = SpaceBotWar::ClientCode->new({
        cache   => $cache,
        secret  => 'topSekret',
    });

    is($client_code->is_valid, 1, "generated ID is valid");
    is($client_code->assert_valid, 1, "assert valid ID");
    diag($client_code->id);
    my $extended = $client_code->extended;
    $client_code->user_id(3);
    is($client_code->extended, $extended+1, "has extended by one");
    $client_code->logged_in(0);
    is($client_code->extended, $extended+2, "has extended by two");

}


1;


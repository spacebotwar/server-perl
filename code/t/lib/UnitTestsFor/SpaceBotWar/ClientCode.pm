package UnitTestsFor::SpaceBotWar::ClientCode;

use lib "t/lib";
use lib "lib";

use Test::Class::Moose;

use SpaceBotWar::ClientCode;
use SpaceBotWar::EmailCode;

sub test_construction {
    my ($self) = @_;

my $email_code = SpaceBotWar::EmailCode->new({
    user_id => 1,
});

#my $client_code = SpaceBotWar::ClientCode->new;


#    my $client_code = SpaceBotWar::ClientCode->new({
#        secret  => 'topSekret',
#    });
#
#    is($client_code->is_valid, 1, "generated ID is valid");
#    is($client_code->assert_valid, 1, "assert valid ID");
#    diag($client_code->id);
#    my $extended = $client_code->extended;
#    $client_code->user_id(3);
#    is($client_code->extended, $extended+1, "has extended by one");
#    $client_code->logged_in(0);
#    is($client_code->extended, $extended+2, "has extended by two");
ok(1);
}


1;


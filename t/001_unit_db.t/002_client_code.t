use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;
use Data::Dumper;

use SpaceBotWar;
use SpaceBotWar::ClientCode;


#diag "CLEAR CACHE";

# Clear the cache to start
my $cache = SpaceBotWar->cache;
$cache->delete('client_code', -1);

#diag "CREATE NEW CLIENT_CODE";
my $client_code = SpaceBotWar::ClientCode->new({
    user_id     => -1,
    logged_in   => 1,
});

is(defined $client_code, 1, "ClientCode is created");

#diag "ABOUT TO VALIDATE CLIENT_CODE";
my $valid_client_code = SpaceBotWar::ClientCode->validate_client_code($client_code->id);
isa_ok($valid_client_code, 'SpaceBotWar::ClientCode', "Is a ClientCode object");

#diag "VALID CLIENT_CODE".Dumper(\$valid_client_code);

is($valid_client_code->user_id, -1, "ClientCode has a valid user ID");

is($valid_client_code->logged_in, 1, "User is logged in");

$valid_client_code = SpaceBotWar::ClientCode->validate_client_code('1660686c-8b5d-4b7c-825d-1d818db8f9ca-2f9285');
isa_ok($valid_client_code, 'SpaceBotWar::ClientCode', "ClientCode is valid 2");

done_testing();


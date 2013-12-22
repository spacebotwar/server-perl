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
use SpaceBotWar::Session;


#diag "CLEAR CACHE";

# Clear the cache to start
my $cache = SpaceBotWar->cache;
$cache->delete('session', -1);

#diag "CREATE NEW SESSION";
my $session = SpaceBotWar::Session->new({
    user_id     => -1,
    logged_in   => 1,
});

is(defined $session, 1, "Session is created");

#diag "ABOUT TO VALIDATE SESSION";
my $valid_session = SpaceBotWar::Session->validate_session($session->id);
isa_ok($valid_session, 'SpaceBotWar::Session', "Is a Session object");

#diag "VALID SESSION".Dumper(\$valid_session);

is($valid_session->user_id, -1, "Session has a valid user ID");

is($valid_session->logged_in, 1, "User is logged in");

$valid_session = SpaceBotWar::Session->validate_session('1660686c-8b5d-4b7c-825d-1d818db8f9ca-2f9285');
isa_ok($valid_session, 'SpaceBotWar::Session', "Session is valid 2");

done_testing();


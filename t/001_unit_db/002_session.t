use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::Session;

my $session = SpaceBotWar::Session->create_session;
is(defined $session, 1, "Session is created");
diag("session = [$session]");

my $valid = SpaceBotWar::Session->validate_session($session);
is($valid, 1, "Session is valid");

$valid = SpaceBotWar::Session->validate_session('cd30ab06-ee02-4a57-9b79-f0da23aad5e5-b65f7e');
is($valid, 1, "Session is valid 2");

done_testing();


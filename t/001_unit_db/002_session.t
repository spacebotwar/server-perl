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

$valid = SpaceBotWar::Session->validate_session('1660686c-8b5d-4b7c-825d-1d818db8f9ca-2f9285');
is($valid, 1, "Session is valid 2");

done_testing();


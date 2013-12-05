use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;

use SpaceBotWar;
use SpaceBotWar::EmailCode;

my $email_code = SpaceBotWar::EmailCode->create_email_code;
is(defined $email_code, 1, "Email Code is created");
diag("email_code = [$email_code]");

my $valid = SpaceBotWar::EmailCode->validate_email_code($email_code);
is($valid, 1, "Email Code is valid");

$valid = SpaceBotWar::EmailCode->validate_email_code('ce22a79d-0b56-47de-a4ad-9fbd1057f0d3-48a54c');
is($valid, 1, "Email Code is valid 2");

done_testing();


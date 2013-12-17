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

# note. this test may be fragile as code is moved around between servers?
$valid = SpaceBotWar::EmailCode->validate_email_code('25138e31-e0c7-40c8-8968-1cb9bd45b7c6-e88a4c');
is($valid, 1, "Email Code is valid 2");

done_testing();


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

# Create a new email code with no data
my $email_code = SpaceBotWar::EmailCode->new({
    timeout_sec => 5,
});
is(defined $email_code, 1, "Email Code is created");
isa_ok($email_code, 'SpaceBotWar::EmailCode');
$email_code->user_id(123);
is($email_code->user_id, 123, 'Correct user_id');

my $code = $email_code->id;
diag("CODE = ".$code);

my $valid = $email_code->validate;
diag("email_code_valid = [$valid]");

is($valid, $email_code, "Email Code is valid");

# Now read it back to get the user_id

my $new_email_code = SpaceBotWar::EmailCode->new({
    id  => $code,
    timeout_sec => 5,
});
is($new_email_code->user_id, $email_code->user_id, "Read back, user_id is valid");

diag("valid2 = [$valid]");
is($email_code->id, $new_email_code->id, "Same ID");
is($new_email_code->user_id, 123, "Retrieved user id");



# Now wait for the timeout
sleep(6);

$new_email_code = SpaceBotWar::EmailCode->new({
    id  => $code,
});
is($new_email_code->user_id, undef, "User ID has expired");



done_testing();


use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../lib";

use Test::More;
use Data::Dumper;
use Try;
use Safe;
use Safe::Hole;

use SpaceBotWar;

my $code_store = SpaceBotWar->db->resultset('CodeStore')->find(1);
diag("code_store = [$code_store]");
my $clone = $code_store->clone;

$clone->code("# this is a test");
$clone->name("Foo");
$clone->title("Test commit");
$clone->description("Test description");
$clone->update;



diag "clone = [$clone]";

done_testing();
1;



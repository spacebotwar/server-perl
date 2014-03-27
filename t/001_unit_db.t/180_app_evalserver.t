use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use App::EvalServer;

my $server = App::EvalServer->new(
    port        => 14400,
    timeout     => 30,
    unsafe      => 1,
);


diag("about to run server [$server]");
$server->run();
diag("about to go asleep");


sleep 100;

$server->shutdown();


ok(1);
done_testing();


package UnitTestsFor::SpaceBotWar::ClientCode;

use lib "lib";

use Test::Class::Moose;


use SpaceBotWar::WebSocket;

sub test_construction {
    my ($self) = @_;

    ok(1);
}

1;
__DATA__
# config-file-type: JSON 1
{   
    "foo" : {
        "bar" : "baz"
    }
}


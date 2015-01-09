package TestsFor::SpaceBotWar::Config;

use lib "lib";

use Test::Class::Moose;
use File::Temp qw(tempfile);

use SpaceBotWar::Config;

sub test_construction_foo {
    my ($self) = @_;

    # unfortunately we need a physical file
    my ($fh, $filename) = tempfile();
    my @lines = <DATA>;
    print $fh @lines;
    close $fh;

    my $config_json = Config::JSON->new(pathToFile => $filename);

    my $config = SpaceBotWar::Config->new({
        filename    => 'foo',
        config_json => $config_json,
    });

    isa_ok($config, 'SpaceBotWar::Config');

    is($config->get('foo/bar'), 'baz', "Can get from config");
}

1;
__DATA__
# config-file-type: JSON 1
{   
    "foo" : {
        "bar" : "baz"
    }
}


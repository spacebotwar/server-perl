package TestsFor::SpaceBotWar::Config;

use lib "lib";

use Test::Class::Moose;
use Test::Mock::Class ':all';
use File::Temp qw(tempfile);

use SpaceBotWar::Config;

sub test_construction_foo {
    my ($self) = @_;

    # unfortunately we need a physical file
    my ($fh, $filename) = tempfile();
    my @lines = <DATA>;
    print $fh @lines;
    close $fh;


    my $mock   = mock_anon_class 'Config::JSON';
    my $mock_config_json = $mock->new_object( { pathToFile => $filename } );
        
    $mock_config_json->mock_return(get => 'baz');

    my $config = SpaceBotWar::Config->new({
        filename    => 'foo',
        config_json => $mock_config_json,
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


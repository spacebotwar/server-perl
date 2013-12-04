package SpaceBotWar;

use Moose;
use FindBin;
FindBin->again;

use Config::JSON;

use namespace::autoclean;
use Module::Find qw(useall);
use Redis;
use SpaceBotWar::Cache;


useall __PACKAGE__;

my $dir = $ENV{SPACEBOTWAR_DIR} || "/data/spacebotwar";

my $config  = Config::JSON->new("$dir/spacebotwar.conf");
my $db      = SpaceBotWar::DB->connect(
    $config->get('db/dsn'),
    $config->get('db/username'),
    $config->get('db/password'), { 
        mysql_enable_utf8   => 1,
        AutoCommit          => 1,
    },
);

my $redis = Redis->new(server => $config->get('redis_server'));

my $cache = SpaceBotWar::Cache->new({
    redis   => $redis,
});


# These are all singletons.
#
sub config {
    return $config;
}

sub db {
    return $db;
}

sub cache {
    return $cache;
}

sub redis {
    return $redis;
}

__PACKAGE__->meta->make_immutable;


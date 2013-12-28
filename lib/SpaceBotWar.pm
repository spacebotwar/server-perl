package SpaceBotWar;

use Moose;
use namespace::autoclean;

use FindBin;
FindBin->again;

use Config::JSON;

use Module::Find qw(useall);
use Redis;
use SpaceBotWar::Cache;
use SpaceBotWar::DB;
use Log::Log4perl;

my $dir = $ENV{SPACEBOTWAR_DIR} || "/data/spacebotwar";

my $_config  = Config::JSON->new("$dir/spacebotwar.conf");
my $_db      = SpaceBotWar::DB->connect(
    $_config->get('db/dsn'),
    $_config->get('db/username'),
    $_config->get('db/password'), { 
        mysql_enable_utf8   => 1,
        AutoCommit          => 1,
    },
);

Log::Log4perl->init($_config->get('log/conf_file'));

my $_redis = Redis->new(server => $_config->get('redis_server'));

my $_cache = SpaceBotWar::Cache->new({
    redis   => $_redis,
});


# These are all singletons.
#
sub config {
    return $_config;
}

sub db {
    return $_db;
}

sub cache {
    return $_cache;
}

sub redis {
    return $_redis;
}

__PACKAGE__->meta->make_immutable;


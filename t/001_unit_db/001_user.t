use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use Try;

use SpaceBotWar;

my $db = SpaceBotWar->db;
ok($db, 'Database Connection Made');

my $tests = {
    create_valid_user   => sub {
        my $user = $db->resultset('User')->assert_create({
            username    => 'nthnsth3E',
            password    => 'Yop_s3cr3t',
            email       => 'me@example.com',
        });

        ok($user, 'created new user');
        $db->txn_rollback;
    },
    cant_create_duplicate_user => sub {
        my $user;
        eval {
            $user = $db->resultset('User')->assert_create({
                username    => 'icydee',
                password    => 'Yop_s3cr3t',
                email       => 'me@example.com',
            });
        };

        is($user, undef, 'cant create a duplicate username');
    },
};


for my $test (sort keys %$tests ) {
    try {
        my $rs = $db->txn_do($tests->{$test});
    }
    catch {
        my $error = shift;
        fail(Dumper($error));
    };
}

done_testing();


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

        my $open_password = 'Yop_s3cr3t';
        my $user = $db->resultset('User')->assert_create({
            username    => ' test_user_1',
            password    => $open_password,
            email       => 'me@example.com',
        });

        ok($user, 'created new user');
        isnt($user->password, $open_password, 'Password encrypted');
        #diag("password: ".$user->password);
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

my $users = $db->resultset('User')->search({
    username    => ' test_user_1',
});
while (my $user = $users->next) {
    $user->delete;
}

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


use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";
#use lib "$FindBin::Bin/../lib";

use Test::More;
use Data::Dumper;
use File::Spec::Functions qw(rel2abs);
#use Rumple;

use SpaceBotWar::RemoteCode;


diag "interpreter? is [".$^X."]";

my @inc = map { +'-I' => rel2abs($_) } @INC;

diag "inc = [".join(" ", @inc). "]";


#my $bar = Rumple::foo();
#diag("rumple = [$bar]");

my $code = <<'END_CODE';
use strict;
use warnings;
use Rumple;
#use Data::Dumper;

my $foo = {
#    one => Rumple::foo(),
    two => 2,
};
#print "DUMPER: ".Dumper(\$foo);
END_CODE



my $remote_code = SpaceBotWar::RemoteCode->new({
    language    => 'perl',
    code        => $code,
    data        => '',
});

$remote_code->execute;

#diag Dumper($remote_code->output);
diag "OUTPUT IS : ".Dumper(\$remote_code->output);
is($remote_code->output->{result}, 'foo');


eval $code;

done_testing();

1;


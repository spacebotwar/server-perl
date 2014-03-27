use strict;
use warnings;

use FindBin;
FindBin->again;
use lib "$FindBin::Bin/../../lib";

use Test::More;
use Data::Dumper;
use File::Spec::Functions qw(rel2abs);
use POSIX qw(setgid);

diag "interpreter? is [".$^X."]";

diag "root user? is [".$<."]";

my $user        = 'nobody';
my $new_uid     = getpwnam($user);

if ($< != 0) {
    diag "Not running as root!";
    done_testing();
    exit;
}

open(GF, ">temp.txt") or die "could not open temp.txt: $!";

chdir "jail" or die("Failed to chdir into jail: $!");
chroot '.' or die("Failed to chroot: $!");

# Drop root privileges

die("Cannot find uid for [$user]") if not defined $new_uid;

$)  = "$new_uid $new_uid";
$(  = $new_uid;
$<  = $>    = $new_uid;
setgid($new_uid);

if ($> != $new_uid or $< != $new_uid) {
    die("Failed to drop root privileges");
}

# This code is running in the jail.
chdir '/';
opendir my ($dh), "." or die "Could not open dir: $!";
my @files = readdir($dh);
closedir $dh;

open(FILE, ">output.txt");
print FILE join("\n", @files);
close(FILE);

print GF "Hello world\n";
close GF;

diag Dumper("@ = [".$@."]");
diag Dumper("INC = [".@INC."]");
diag Dumper("_ = [".$_."]");




ok(1);
done_testing();

1;


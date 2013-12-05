package SpaceBotWar::EmailCode;

use Moose;
use namespace::autoclean;
use UUID::Tiny ':std';
use SpaceBotWar;
use Digest::MD5 qw(md5_hex);



# Class methods
#

# Create an email code
#
sub create_email_code {
    my ($class) = @_;

    my $secret  = SpaceBotWar->config->get('email_secret');
    my $uuid    = create_uuid_as_string(UUID_V4);
    my $digest  = substr(md5_hex($uuid.$secret), 0, 6);
    return $uuid."-".$digest;
}

# Validate an email code
#
sub validate_email_code {
    my ($class, $email_code) = @_;

    return if not defined $email_code;
    my $secret  = SpaceBotWar->config->get('email_secret');
    my $uuid    = substr($email_code, 0, 36);
    my $test    = $uuid."-".substr(md5_hex($uuid.$secret), 0, 6);
    return $test eq $email_code ? 1 : 0;
}

# Validate an email code with confess
#
sub assert_validate_email_code {
    my ($class, $email_code) = @_;

    confess [1000, "Email Code is missing" ]            if not defined $email_code;
    confess [1001, "Invalid Email Code", $email_code ]  if not $class->validate_email_code;
    return 1;
}


__PACKAGE__->meta->make_immutable;


package SpaceBotWar::DB::ResultSet::User;

use Moose;
use namespace::autoclean;
use Data::Validate::Email qw(is_email);
use Crypt::SaltedHash;

extends 'SpaceBotWar::DB::ResultSet';

# Assert that a username is available
# throw an error if not
#
sub assert_username_available {
    my ($self, $username) = @_;

    confess [1001, 'Username must be at least 3 characters long' ] if not defined $username;
    confess [1001, 'Username must be at least 3 characters long', $username] if length($username) < 3;

    my ($row) = $self->search({
        name    => $username,
    });
    confess [1001, 'Username not available', $username] if $row;
    return 1;

}

# Assert that an email address is valid
#
sub assert_email_valid {
    my ($self, $email) = @_;

    confess [1001, 'Email is missing' ]         if not defined $email;
    confess [1001, 'Email is invalid', $email]  if not is_email($email);
    return 1;
}

# Assert that a password is valid
#
sub assert_password_valid {
    my ($self, $password) = @_;

    confess [1001, 'Password is missing' ]                                                  if not defined $password;
    confess [1001, 'Password must be at least 5 characters long', $password ]               if length($password) < 5;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[0-9]/;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[a-z]/;
    confess [1001, 'Password must contain numbers, lowercase and uppercase', $password ]    if not $password =~ m/[A-Z]/;
    return 1;
}

# Assert that everything is correct to create a new User
#
sub assert_create {
    my ($self, $args) = @_;

    $self->assert_username_available($args->{username});
    $self->assert_email_valid($args->{email});
    $self->assert_password_valid($args->{password});

    my $csh = Crypt::SaltedHash->new->add($args->{password})->generate;

    my $user = $self->create({
        name        => $args->{username},
        password    => $csh,
        email       => $args->{email},
    });

    confess [1002, 'Could not create new user' ] if not $user;
    
    return $user;
}

# Assert that a user can log in with a password
#
sub assert_login_with_password {
    my ($self, $args) = @_;

    confess [1001, 'username is missing' ]      if not defined $args->{username};
    confess [1001, 'password is missing' ]      if not defined $args->{password};

    my ($user) = $self->search({
        name    => $args->{username},
    });
    confess [1001, 'Incorrect credentials']     if not defined $user;
    confess [1001, 'Incorrect credentials']     if not $user->check_password($args->{password});

    return $user;
}



__PACKAGE__->meta->make_immutable(inline_constructor => 0);

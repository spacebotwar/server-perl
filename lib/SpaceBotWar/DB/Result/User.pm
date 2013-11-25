package SpaceBotWar::DB::Result::User;

use Moose;
use namespace::autoclean;

use utf8;
no warnings qw(uninitialized);
extends 'SpaceBotWar::DB::Result';

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar',    size => 30,     is_nullable => 0    },
    password                => { data_type => 'char',       size => 43                          },
    email                   => { data_type => 'varchar',    size => 255,    is_nullable => 1    },
    password_recovery_key   => { data_type => 'varchar',    size => 36,     is_nullable => 1    },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_password_recovery_key', fields => ['password_recovery_key']);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


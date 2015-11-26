package SpaceBotWar::DB::Result::League;

use Moose;
use namespace::autoclean;

use utf8;
no warnings qw(uninitialized);
extends 'SpaceBotWar::DB::Result';

__PACKAGE__->table('league');
__PACKAGE__->add_columns(
    name                    => { data_type => 'varchar',    size => 40 },
    parent                  => { data_type => 'int',        },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_program_name_key', fields => ['name']);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


package SpaceBotWar::DB::Result::Competition;

use Moose;
use namespace::autoclean;

use utf8;
no warnings qw(uninitialized);
extends 'SpaceBotWar::DB::Result';

__PACKAGE__->table('competition');
__PACKAGE__->add_columns(
    program_a               => { data_type => 'int',        is_nullable => 0 },
    program_b               => { data_type => 'int',        is_nullable => 0 },
    status                  => { data_type => 'varchar',    size => 20 },
    points_a                => { data_type => 'int',        default => 0 },
    points_b                => { data_type => 'int',        default => 0 },
    time_a                  => { data_type => 'int',        default => 0 },
    time_b                  => { data_type => 'int',        default => 0 },
    match_time              => { data_type => 'datetime',   },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_program_a_key', fields => ['program_a']);
    $sqlt_table->add_index(name => 'idx_program_b_key', fields => ['program_b']);
}

# Status can be one of
#
#   prematch    - The match has not started, match_time is estimated
#   running     - The match is currently running
#   completed   - The match has completed
#   abandoned   - The match was abandoned
#

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


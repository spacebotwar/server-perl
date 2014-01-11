package SpaceBotWar::DB::Result::Program;

use Moose;
use namespace::autoclean;

use utf8;
no warnings qw(uninitialized);
extends 'SpaceBotWar::DB::Result';

__PACKAGE__->table('program');
__PACKAGE__->add_columns(
    commit_key              => { data_type => 'varchar',    size => 40  },
    name                    => { data_type => 'varchar',    size => 30,     is_nullable => 0    },
    owner_id                => { data_type => 'int',        is_nullable => 0    },
    status                  => { data_type => 'varchar',    size => 20 },
    league                  => { data_type => 'int',        },
    rank                    => { data_type => 'int',        },
    parent_program          => { data_type => 'int',        is_nullable => 1    },
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->add_index(name => 'idx_program_name_key', fields => ['name']);
    $sqlt_table->add_index(name => 'idx_program_commit_key', fields => ['commit_key']);
}

# Status can be one of -> can move to state
#   editable    Initial state, when created -> tested_1
#   tested_1    Will compile -> editable, tested_2
#   tested_2    Will run and exit -> editable, tested_3
#   tested_3    Will run against several examples -> editable, validated
#   validated   All tests passed -> editable, contender
#   contender   Entered into tournament -> rejected
#   rejected    Has been rejected due to problems

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


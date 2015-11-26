package SpaceBotWar::DB::Result::CodeStore;

use Moose;
use namespace::autoclean;
use Data::Dumper;

use utf8;
no warnings qw(uninitialized);
extends 'SpaceBotWar::DB::Result';

__PACKAGE__->table('code_store');
__PACKAGE__->add_columns(
    code                => { data_type => 'text',       size => 65500,      is_nullable => 0 },
    name                => { data_type => 'varchar',    size => 45,         is_nullable => 0 },
    title               => { data_type => 'varchar',    size => 256,        is_nullable => 1 },
    description         => { data_type => 'varchar',    size => 1024,       is_nullable => 1 },
    owner_id            => { data_type => 'int',        size => 11,         is_nullable => 0 },
    parent_id           => { data_type => 'int',        size => 11,         is_nullable => 0 },   
);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
#    $sqlt_table->add_index(name => 'idx_name', fields => ['name']);
}

# Clone the Result and create a new instance.
# linking it to this (the parent)
# 
sub clone {
    my ($self) = @_;

    my $clone = $self->result_source->resultset->create({
        name            => $self->name,
        title           => $self->title,
        description     => $self->description,
        owner_id        => $self->owner_id,
        parent_id       => $self->id,
        code            => $self->code,
    });
    return $clone;
}


__PACKAGE__->meta->make_immutable(inline_constructor => 0);


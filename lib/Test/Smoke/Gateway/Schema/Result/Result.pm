package Test::Smoke::Gateway::Schema::Result::Result;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Test::Smoke::Gateway::Schema::Result::Result

=cut

__PACKAGE__->table("result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'result_id_seq'

=head2 config_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 io_env

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 locale

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 output

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 summary

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 statistics

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "result_id_seq",
  },
  "config_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "io_env",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "locale",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "output",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "summary",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "statistics",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 config

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::Config>

=cut

__PACKAGE__->belongs_to(
  "config",
  "Test::Smoke::Gateway::Schema::Result::Config",
  { id => "config_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-30 14:31:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gN0Dzf3m/aOrveYdQVYocQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;

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

=head2 config_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 0

=head2 io_env

  data_type: 'varchar'
  is_nullable: 0

=head2 locale

  data_type: 'varchar'
  is_nullable: 1

=head2 output

  data_type: 'varchar'
  is_nullable: 0

=head2 summary

  data_type: 'varchar'
  is_nullable: 0

=head2 statistics

  data_type: 'varchar'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "config_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 0 },
  "io_env",
  { data_type => "varchar", is_nullable => 0 },
  "locale",
  { data_type => "varchar", is_nullable => 1 },
  "output",
  { data_type => "varchar", is_nullable => 0 },
  "summary",
  { data_type => "varchar", is_nullable => 0 },
  "statistics",
  { data_type => "varchar", is_nullable => 1 },
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-20 14:21:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1RQavxz+0aUnmdr4S5hg5w


# You can replace this text with custom content, and it will be preserved on regeneration
1;

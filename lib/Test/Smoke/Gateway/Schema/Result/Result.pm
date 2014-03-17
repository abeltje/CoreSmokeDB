use utf8;
package Test::Smoke::Gateway::Schema::Result::Result;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Test::Smoke::Gateway::Schema::Result::Result

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<result>

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

=head2 summary

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 statistics

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 stat_cpu_time

  data_type: 'double precision'
  is_nullable: 1

=head2 stat_tests

  data_type: 'integer'
  is_nullable: 1

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
  "stat_cpu_time",
  { data_type => "double precision", is_nullable => 1 },
  "stat_tests",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

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
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 failures_for_env

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::FailureForEnv>

=cut

__PACKAGE__->has_many(
  "failures_for_env",
  "Test::Smoke::Gateway::Schema::Result::FailureForEnv",
  { "foreign.result_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-15 16:23:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gk8da4MAS1UOA32SHxLs/w

sub test_env {
    my $self = shift;
    return $self->locale
        ? join(":", $self->io_env, $self->locale)
        : $self->io_env;
}

1;

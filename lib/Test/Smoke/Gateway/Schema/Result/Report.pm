package Test::Smoke::Gateway::Schema::Result::Report;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Test::Smoke::Gateway::Schema::Result::Report

=cut

__PACKAGE__->table("report");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 sconfig_id

  data_type: 'int'
  is_foreign_key: 1
  is_nullable: 1

=head2 duration

  data_type: 'int'
  is_nullable: 1

=head2 config_count

  data_type: 'int'
  is_nullable: 1

=head2 smoke_date

  data_type: 'timestamp with time zone'
  is_nullable: 0

=head2 perl_id

  data_type: 'varchar'
  is_nullable: 0

=head2 git_id

  data_type: 'varchar'
  is_nullable: 0

=head2 git_describe

  data_type: 'varchar'
  is_nullable: 0

=head2 applied_patches

  data_type: 'varchar'
  is_nullable: 1

=head2 hostname

  data_type: 'varchar'
  is_nullable: 0

=head2 architecture

  data_type: 'varchar'
  is_nullable: 0

=head2 osname

  data_type: 'varchar'
  is_nullable: 0

=head2 osversion

  data_type: 'varchar'
  is_nullable: 0

=head2 cpu_count

  data_type: 'varchar'
  is_nullable: 1

=head2 cpu_description

  data_type: 'varchar'
  is_nullable: 1

=head2 cc

  data_type: 'varchar'
  is_nullable: 0

=head2 ccversion

  data_type: 'varchar'
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1

=head2 test_jobs

  data_type: 'varchar'
  is_nullable: 1

=head2 lc_all

  data_type: 'varchar'
  is_nullable: 1

=head2 lang

  data_type: 'varchar'
  is_nullable: 1

=head2 manifest_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 compiler_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 skipped_tests

  data_type: 'varchar'
  is_nullable: 1

=head2 harness_only

  data_type: 'varchar'
  is_nullable: 1

=head2 summary

  data_type: 'varchar'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "sconfig_id",
  { data_type => "int", is_foreign_key => 1, is_nullable => 1 },
  "duration",
  { data_type => "int", is_nullable => 1 },
  "config_count",
  { data_type => "int", is_nullable => 1 },
  "smoke_date",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "perl_id",
  { data_type => "varchar", is_nullable => 0 },
  "git_id",
  { data_type => "varchar", is_nullable => 0 },
  "git_describe",
  { data_type => "varchar", is_nullable => 0 },
  "applied_patches",
  { data_type => "varchar", is_nullable => 1 },
  "hostname",
  { data_type => "varchar", is_nullable => 0 },
  "architecture",
  { data_type => "varchar", is_nullable => 0 },
  "osname",
  { data_type => "varchar", is_nullable => 0 },
  "osversion",
  { data_type => "varchar", is_nullable => 0 },
  "cpu_count",
  { data_type => "varchar", is_nullable => 1 },
  "cpu_description",
  { data_type => "varchar", is_nullable => 1 },
  "cc",
  { data_type => "varchar", is_nullable => 0 },
  "ccversion",
  { data_type => "varchar", is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1 },
  "test_jobs",
  { data_type => "varchar", is_nullable => 1 },
  "lc_all",
  { data_type => "varchar", is_nullable => 1 },
  "lang",
  { data_type => "varchar", is_nullable => 1 },
  "manifest_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "compiler_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "skipped_tests",
  { data_type => "varchar", is_nullable => 1 },
  "harness_only",
  { data_type => "varchar", is_nullable => 1 },
  "summary",
  { data_type => "varchar", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "git_id_smoke_date_hostname_architecture_cc_ccversion_unique",
  [
    "git_id",
    "smoke_date",
    "hostname",
    "architecture",
    "cc",
    "ccversion",
  ],
);

=head1 RELATIONS

=head2 sconfig

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::SmokeConfig>

=cut

__PACKAGE__->belongs_to(
  "sconfig",
  "Test::Smoke::Gateway::Schema::Result::SmokeConfig",
  { id => "sconfig_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 configs

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::Config>

=cut

__PACKAGE__->has_many(
  "configs",
  "Test::Smoke::Gateway::Schema::Result::Config",
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-04-20 15:13:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nAvl78xUCY4e8Xcs3sa/5w


# You can replace this text with custom content, and it will be preserved on regeneration
1;

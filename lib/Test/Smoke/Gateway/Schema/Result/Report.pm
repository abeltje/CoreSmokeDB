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
  sequence: 'report_id_seq'

=head2 sconfig_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 duration

  data_type: 'integer'
  is_nullable: 1

=head2 config_count

  data_type: 'integer'
  is_nullable: 1

=head2 reporter

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_perl

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_revision

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_version

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoker_version

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_date

  data_type: 'timestamp with time zone'
  is_nullable: 0

=head2 perl_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 git_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 git_describe

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 applied_patches

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 hostname

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 architecture

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 osname

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 osversion

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 cpu_count

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 cpu_description

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 cc

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 ccversion

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 username

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 test_jobs

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lc_all

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lang

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 manifest_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 compiler_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 skipped_tests

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 harness_only

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 summary

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "report_id_seq",
  },
  "sconfig_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "duration",
  { data_type => "integer", is_nullable => 1 },
  "config_count",
  { data_type => "integer", is_nullable => 1 },
  "reporter",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_perl",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_revision",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_version",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoker_version",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_date",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "perl_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "git_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "git_describe",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "applied_patches",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "hostname",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "architecture",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "osname",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "osversion",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "cpu_count",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "cpu_description",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "cc",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "ccversion",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "username",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "test_jobs",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lc_all",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lang",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "manifest_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "compiler_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "skipped_tests",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "harness_only",
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
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "report_git_id_smoke_date_hostname_architecture_cc_ccversion_key",
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


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-16 13:38:31
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ipUIWeGceQa9y3u5sgMfmQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;

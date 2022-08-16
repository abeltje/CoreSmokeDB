use utf8;
package Test::Smoke::Gateway::Schema::Result::FailureForEnv;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Test::Smoke::Gateway::Schema::Result::FailureForEnv

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<failures_for_env>

=cut

__PACKAGE__->table("failures_for_env");

=head1 ACCESSORS

=head2 result_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 failure_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "result_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "failure_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<failures_for_env_result_id_failure_id_key>

=over 4

=item * L</result_id>

=item * L</failure_id>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "failures_for_env_result_id_failure_id_key",
  ["result_id", "failure_id"],
);

=head1 RELATIONS

=head2 failure

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::Failure>

=cut

__PACKAGE__->belongs_to(
  "failure",
  "Test::Smoke::Gateway::Schema::Result::Failure",
  { id => "failure_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 result

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::Result>

=cut

__PACKAGE__->belongs_to(
  "result",
  "Test::Smoke::Gateway::Schema::Result::Result",
  { id => "result_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-08-16 16:01:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5LmKftsEPXeOy2aHfKJ6Ig


# You can replace this text with custom content, and it will be preserved on regeneration
1;

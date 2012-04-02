package Test::Smoke::Gateway::Schema::Result::Failure;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Test::Smoke::Gateway::Schema::Result::Failure

=cut

__PACKAGE__->table("failure");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'failure_id_seq'

=head2 test

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 status

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 extra

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
    sequence          => "failure_id_seq",
  },
  "test",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "status",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "extra",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("failure_test_status_extra_key", ["test", "status", "extra"]);

=head1 RELATIONS

=head2 failures_for_env

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::FailureForEnv>

=cut

__PACKAGE__->has_many(
  "failures_for_env",
  "Test::Smoke::Gateway::Schema::Result::FailureForEnv",
  { "foreign.failure_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2012-03-31 10:35:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UPdNUkmpkL5VyfVlifHrfA


# You can replace this text with custom content, and it will be preserved on regeneration
1;

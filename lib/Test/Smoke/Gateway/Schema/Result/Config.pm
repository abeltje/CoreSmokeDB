use utf8;
package Test::Smoke::Gateway::Schema::Result::Config;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Test::Smoke::Gateway::Schema::Result::Config

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<config>

=cut

__PACKAGE__->table("config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'config_id_seq'

=head2 report_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 arguments

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 debugging

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 started

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 duration

  data_type: 'integer'
  is_nullable: 1

=head2 cc

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 ccversion

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
    sequence          => "config_id_seq",
  },
  "report_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "arguments",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "debugging",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "started",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "duration",
  { data_type => "integer", is_nullable => 1 },
  "cc",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "ccversion",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 report

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::Report>

=cut

__PACKAGE__->belongs_to(
  "report",
  "Test::Smoke::Gateway::Schema::Result::Report",
  { id => "report_id" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 results

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::Result>

=cut

__PACKAGE__->has_many(
  "results",
  "Test::Smoke::Gateway::Schema::Result::Result",
  { "foreign.config_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-09-15 16:23:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hvt6Df/nibkpzVnPK4HLOw


sub c_compiler_key {
    my $self = shift;
    return join("##", $self->cc, $self->ccversion);
}

sub c_compiler_label {
    my $self = shift;
    return join(" - ", $self->cc, $self->ccversion);
}

sub c_compiler_pair {
    my $self = shift;
    return {value => $self->c_compiler_key, label => $self->c_compiler_label};
}

sub full_arguments {
    my $self = shift;
    return $self->debugging eq 'D'
        ? join(" ", $self->arguments, 'DEBUGGING')
        : $self->arguments;
}

1;

package Test::Smoke::Gateway::Schema::Result::SmokeConfig;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';


=head1 NAME

Test::Smoke::Gateway::Schema::Result::SmokeConfig

=cut

__PACKAGE__->table("smoke_config");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'smoke_config_id_seq'

=head2 md5

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}
  original: {data_type => "varchar"}

=head2 config

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
    sequence          => "smoke_config_id_seq",
  },
  "md5",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "config",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("smoke_config_md5_key", ["md5"]);

=head1 RELATIONS

=head2 reports

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::Report>

=cut

__PACKAGE__->has_many(
  "reports",
  "Test::Smoke::Gateway::Schema::Result::Report",
  { "foreign.sconfig_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-08-15 16:40:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:cT64hOcatFMI3WLe/C7rfw


# You can replace this text with custom content, and it will be preserved on regeneration
1;

use utf8;
package Test::Smoke::Gateway::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07020 @ 2012-04-02 22:16:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pch59BgrYy7frtW0MFWhew

our $APIVERSION = 3;

use Exception::Class (
    'Test::Smoke::Gateway::Exception' =>
    'Test::Smoke::Gateway::VersionMismatchException' => {
        isa => 'Test::Smoke::Gateway::Exception',
        alias => 'throw_version_mismatch'
    },
);


sub connection {
    my $self = shift;
    $self->next::method(@_);
    $self->_check_version($_[3]);
    return $self;
}

sub _check_version {
    my $self = shift;
    my ($args) = @_;
    $args ||= { };

    return 1 if $args->{ignore_version};

    my $dbversion = $self->resultset('TsgatewayConfig')->find(
        {name => 'dbversion'}
    )->value;

    if ($APIVERSION > $dbversion) {
        throw_version_mismatch(
            sprintf(
                "APIVersion %d does not match DBVersion %d",
                $APIVERSION,
                $dbversion
            )
        );
    }
    return $self;
}

=head2 deploy()

    after deploy => sub { };

Populate the tsgateway_config-table with data.

=cut

sub deploy {
    my $self = shift;
    $self->next::method(@_);

    $self->storage->dbh->do(<<EOQ);
ALTER TABLE report
DROP COLUMN plevel
EOQ
    $self->storage->dbh->do(<<EOQ);
ALTER TABLE report
 ADD COLUMN plevel varchar GENERATED ALWAYS AS (git_describe_as_plevel(git_describe)) STORED
EOQ

    $self->resultset('TsgatewayConfig')->populate(
        [
            {name => 'dbversion', value => $APIVERSION},
        ]
    );
}

1;

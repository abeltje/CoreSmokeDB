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

our $APIVERSION = 1;

use Exception::Class (
    'Test::Smoke::Gateway::Exception' =>
    'Test::Smoke::Gateway::VersionMismatchException' => {
        isa => 'Test::Smoke::Gateway::Exception',
        alias => 'throw_version_mismatch'
    },
);

sub connect {
    my $self = shift;
    $self->next::method(@_);

    my $dbversion = $self->resultset('tsgateway_config')->find(
        {name => 'dbversion'}
    )->value;

    if ($APIVERSION != $dbversion) {
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

1;

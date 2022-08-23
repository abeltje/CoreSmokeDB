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
    my $dbh = $self->storage->dbh;

    if ($self->storage->connect_info->[0] =~ /dbi:SQLite/) {
        $self->sqlite_pre_deploy();
    }
    else {
        $self->pg_pre_deploy();
    }

    $self->next::method(@_);

    $dbh->do(<<EOQ);
ALTER TABLE report
DROP COLUMN plevel
EOQ
    $dbh->do(<<EOQ);
ALTER TABLE report
 ADD COLUMN plevel varchar GENERATED ALWAYS AS (git_describe_as_plevel(git_describe)) STORED
EOQ

    $self->resultset('TsgatewayConfig')->populate(
        [
            {name => 'dbversion', value => $APIVERSION},
        ]
    );
}

use constant SQLITE_DETERMINISTIC => 0x800; # from sqlite3.c source in DBD::SQLite

sub sqlite_pre_deploy {
    my $self = shift;
    my $dbh = $self->storage->dbh;

    $dbh->sqlite_create_function(
        'git_describe_as_plevel',
        1, \&plevel,
        SQLITE_DETERMINISTIC
    );
}

sub pg_pre_deploy {
    my $self = shift;
    my $dbh = $self->storage->dbh;

    $dbh->do(<<'EOQ');
CREATE OR REPLACE FUNCTION public.git_describe_as_plevel(character varying)
    RETURNS character varying
    LANGUAGE plpgsql
    IMMUTABLE
AS $function$
    DECLARE
        vparts varchar array [5];
        plevel varchar;
        clean  varchar;
    BEGIN
        SELECT regexp_replace($1, E'^v', '') INTO clean;
        SELECT regexp_replace(clean, E'-g\.\+$', '') INTO clean;

        SELECT regexp_split_to_array(clean, E'[\.\-]') INTO vparts;

        SELECT vparts[1] || '.' INTO plevel;
        SELECT plevel || lpad(vparts[2], 3, '0') INTO plevel;
        SELECT plevel || lpad(vparts[3], 3, '0') INTO plevel;
        if array_length(vparts, 1) = 3 then
            SELECT array_append(vparts, '0') INTO vparts;
        end if;
        if regexp_matches(vparts[4], 'RC') = array['RC'] then
            SELECT plevel || vparts[4] INTO plevel;
        else
            SELECT plevel || 'zzz' INTO plevel;
        end if;
        SELECT plevel || lpad(vparts[array_upper(vparts, 1)], 3, '0') INTO plevel;

        return plevel;
    END;
$function$ ;
EOQ
}

sub plevel {
    my $data = shift;

    (my $git_describe  = $data) =~ s{^v}{};
    $git_describe =~ s{-g[0-9a-f]+$}{}i;

    my @vparts = split(/[.-]/, $git_describe, 5);
    my $plevel = sprintf("%u.%03u%03u", @vparts[0..2]);
    if (@vparts < 4) {
        push(@vparts, '0');
    }
    my $rc = $vparts[3] =~ m{RC}i ? $vparts[3] : 'zzz';
    $plevel .= $rc;
    $plevel .= sprintf("%03u", $vparts[-1] // '0');

    return $plevel;
}

1;

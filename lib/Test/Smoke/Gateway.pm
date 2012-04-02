package Test::Smoke::Gateway;
use Moose;

require Digest::MD5;
require JSON::PP;

has schema => (is => 'ro');

our $VERSION = 0.03;

=head1 NAME

Test::Smoke::Gateway - The basic gateway between smoker and The Core Smoke Database.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 post_report($data)

Handle http-post to /report/ to the database.

Returns the database object.

=cut

sub post_report {
    my ($self, $data) = @_;

    my $sconfig = $self->post_smoke_config(delete $data->{'_config'});

    my $report_data = {
        %{ delete $data->{'sysinfo'} },
        sconfig_id => $sconfig->id,
    };
    $report_data->{lc($_)} = delete $report_data->{$_} for keys %$report_data;

    my @to_unarray = qw/skipped_tests applied_patches compiler_msgs manifest_msgs/;
    $report_data->{$_} = join("\n", @{delete($data->{$_}) || []}) for @to_unarray;

    my @other_data = qw/harness_only harness3opts summary log_file out_file/;
    $report_data->{$_} = delete $data->{$_} for @other_data;

    my $configs = delete $data->{'configs'};
    return $self->schema->txn_do(
        sub {
            my $r = $self->schema->resultset('Report')->create($report_data);
            for my $config (@$configs) {
                my $results = delete $config->{'results'};

                my $conf = $r->create_related('configs', $config);

                for my $result (@$results) {
                    my $failures = delete $result->{'failures'};
                    my $res = $conf->create_related('results', $result);

                    for my $failure (@$failures) {
                        $failure->{'extra'} = join("\n", @{$failure->{'extra'}});
                        my $db_failure = $self->schema->resultset(
                            'Failure'
                        )->find_or_create(
                            $failure,
                            {key => 'failure_test_status_extra_key'}
                        );
                        $self->schema->resultset('FailureForEnv')->create(
                            {
                                result_id  => $res->id,
                                failure_id => $db_failure->id,
                            }
                        );
                    }
                }
            }
            return $r;
        }
    );
};

=head2 get_report($id)

Fetches the report from the database.

Returns the database object.

=cut

sub get_report {
    my ($self, $id) = @_;

    my $report = $self->schema->resultset('Report')->find($id);

    return $report;
}

=head2 post_smoke_config($data)

Checks to see if this smoke_config is already in the database. If not,
insert it.

Returns the database object.

=cut

sub post_smoke_config {
    my ($self, $sconfig) = @_;

    my $all_data = "";
    for my $key ( sort keys %$sconfig ) {
        $all_data .= $sconfig->{$key} || "";
    }
    my $md5 = Digest::MD5::md5_hex($all_data);

    my $sc_data = $self->schema->resultset('SmokeConfig')->find(
        $md5,
        { key => 'smoke_config_md5_key' }
    );

    if ( ! $sc_data ) {
        $sc_data = $self->schema->txn_do(
            sub {
                my $json = JSON::PP->new()->utf8(1)->encode($sconfig);
                return $self->schema->resultset('SmokeConfig')->create(
                    {
                        md5    => $md5,
                        config => $json,
                    }
                );
            }
        );
    }
    return $sc_data;
}

sub search {
    my ($self, $data) = @_;

}

sub search_blank {
    my $self = shift;
    

    return {
        ososversion => $self->get_osname_osversion,
        architecture => $self->get_architecture,
    };
}

sub get_osname_osversion {
    my $self = shift;
    my $ososversion = $self->schema->resultset('Report')->search(
        undef,
        {
            columns  => [qw/osname osversion/],
            group_by => [qw/osname osversion/],
        },
    );
    return [
        map {
            my $record = {
                value => join('##',  $_->osname, $_->osversion),
                label => join(' - ', $_->osname, $_->osversion),
            }
        } $ososversion->all(),
    ];
}

sub get_architecture {
    my $self = shift;
    my $architecture = $self->schema->resultset('Report')->search(
        undef,
        {
            columns  => [qw/architecture/],
            group_by => [qw/architecture/],
        },
    );
    return [
        map {
            my $record = {
                value => $_->architecture,
                label => $_->architecture,
            }
        } $architecture->all(),
    ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 STUFF

(c) MMXI - Abe Timmerman <abeltje@cpan.org>

=cut

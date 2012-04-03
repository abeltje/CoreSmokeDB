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
                for my $field (qw/cc ccversion/) {
                    $config->{$field} ||= '?';
                }

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
                            {key => 'failure_test_key'}
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
    my $self = shift;
    my ($data) = @_;
    
    my $perlversion_list = $self->get_perlversion_list;
    my $perl_latest = $perlversion_list->[0]{label};
    my $pv_selected = $data->{perl_version} || $perl_latest;
    my $aov_selected = $data->{arch_os_ver} // '';
    my %filter;
    (
        $filter{architecture},
        $filter{osname},
        $filter{osversion},
    ) = split /##/, $aov_selected, 3;
    while (my ($k, $v) = each %filter) {
        delete $filter{$k} if ! $v;
    }

    my ($whatnext) = split " ", lc($data->{whatnext} || 'list');
    my $page = $data->{page_selected} || 1;
    my $reports;
    if ($whatnext eq 'list') {
        $pv_selected = '%' if !$data->{perl_version};
        $reports = $self->get_reports_by_date($pv_selected, $page);
    }
    else {
        $reports = $self->get_reports_by_perl_version($pv_selected, \%filter);
    }

    return {
        perl_latest   => $perl_latest,
        perl_versions => $perlversion_list,
        pv_selected   => $pv_selected,
        page_selected => $page,
        whatnext      => $whatnext,
        arch_os_ver   => $self->get_architecture_os,
        aov_selected  => $aov_selected,
        reports       => $reports,
    };
}

sub get_reports_by_perl_version {
    my $self = shift;
    my ($pattern, $filter) = @_;
    $pattern ||= '%';
    $pattern=~ s/\*/%/g;

    my $sr = $self->schema->resultset('Report');
    my $reports = $sr->search(
        {
            perl_id    => { -like => $pattern },
            smoke_date => {
                '=' => $sr->search(
                    {
                        architecture => {'=' => \'me.architecture'},
                        hostname     => {'=' => \'me.hostname'},
                        osname       => {'=' => \'me.osname'},
                        osversion    => {'=' => \'me.osversion'},
                        perl_id      => {'=' => \'me.perl_id'},
                    },
                    { alias => 'rr' }
                )->get_column('smoke_date')->max_rs->as_query
            },
            %$filter,
        },
        {
            order_by => [qw/architecture hostname osname osversion/],
        }
    );
    return [ $reports->all() ];
}

sub get_reports_by_date {
    my $self = shift;
    my ($pattern, $page) = @_;
    $pattern ||= '%';
    $pattern =~ s/\*/%/g;
    $page ||= 1;

    my $reports = $self->schema->resultset('Report')->search(
        {
            perl_id => { -like => $pattern },
        },
        {
            order_by => { -desc => 'smoke_date' },
            page     => $page,
            rows     => 25,
        }
    );

    return [ $reports->all() ];
}

sub get_architecture_os {
    my $self = shift;
    my $architecture = $self->schema->resultset('Report')->search(
        undef,
        {
            columns  => [qw/architecture osname osversion/],
            group_by => [qw/architecture osname osversion/],
            order_by => [qw/architecture osname osversion/],
        },
    );
    return [
        map {
            my $record = {
                value => join(
                    "##",
                    $_->architecture,
                    $_->osname,
                    $_->osversion
                ),
                label => join(
                    " - ",
                    $_->architecture,
                    $_->osname,
                    $_->osversion
                ),
            }
        } $architecture->all(),
    ];
}

sub get_perlversion_list {
    my $self = shift;
    my ($pattern) = @_;
    $pattern ||= '%';
    $pattern =~ s/\*/%/g;
    
    my $pversions = $self->schema->resultset('Report')->search(
        {
            perl_id => { -like => $pattern }
        },
        {
            columns  => [qw/perl_id/],
            group_by => [qw/perl_id/],
            order_by => {-desc => 'perl_id'},
        }
    );
    return [
        map {
            my $record = {
                value => $_->perl_id,
                label => $_->perl_id,
            };
        } $pversions->all()
    ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 STUFF

(c) MMXI - Abe Timmerman <abeltje@cpan.org>

=cut

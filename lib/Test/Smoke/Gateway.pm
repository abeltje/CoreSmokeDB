package Test::Smoke::Gateway;
use Moose;

use Date::Parse;
use Digest::MD5;
use JSON;
use Params::Validate ':all';
use POSIX qw/strftime/;

has schema => (is => 'ro', required => 1);

has reports_per_page => (
    is      => 'ro',
    isa     => 'Int',
    default => 25
);

our $VERSION = 0.07;

=head1 NAME

Test::Smoke::Gateway - The basic gateway between smoker and The Core Smoke Database.

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 $gw->api_get_reports_from_date($epoch)

Returns a list of report-id's that have a smoke_date after C<$epoch>.

=cut

sub api_get_reports_from_date {
    my $self = shift;
    my ($epoch) = validate_pos(
        @_,
        {
            callbacks => {
                'date_parse' => sub {
                    my $value = shift;
                    return 1 if $value =~ /^[1-9][0-9]*$/;
                    my $epoch = str2time($value);
                    $_[0][0] = $epoch if $epoch;
                    return $epoch;
                },
            },
            optional => 0
        }
    );

    my $reports = $self->schema->resultset('Report')->search(
        {
            smoke_date => { '>=' => strftime("%F %T %Z", gmtime($epoch)) }
        },
        {
            order_by => { -asc => ['smoke_date', 'id'] }
        }
    );
    return [map $_->id, $reports->all()];
}

=head2 $gw->api_get_report_data($id)

Returns the data-structure from the database.

=cut

sub api_get_report_data {
    my $self = shift;
    my ($id) = validate_pos(@_, {regex => qr/^[1-9][0-9]*$/, optional => 0});

    my $report = $self->schema->resultset('Report')->find($id);

    my %data = $report->get_inflated_columns;
    $data{configs} = [ ];
    for my $config ($report->configs) {
        push @{$data{configs}}, {$config->get_inflated_columns};
        $data{configs}[-1]{results} = [ ];
        for my $result ($config->results) {
            push(
                @{$data{configs}[-1]{results}},
                {$result->get_inflated_columns}
            );
            $data{configs}[-1]{results}[-1]{failures} = [ ];
            for my $failure ($result->failures_for_env) {
                push(
                    @{$data{configs}[-1]{results}[-1]{failures}},
                    {$failure->failure->get_inflated_columns}
                );
            }
        }
    }

    return \%data;
}

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

    my @to_unarray = qw/
        skipped_tests applied_patches
        compiler_msgs manifest_msgs nonfatal_msgs
    /;
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
                my $json = JSON->new()->utf8(1)->encode($sconfig);
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
    my $perl_latest = $perlversion_list->[0]{value};
    my $pv_selected = $data->{perl_version} || $perl_latest;
    my $aov_selected = $data->{arch_os_ver} // '';
    my $compiler_version = $data->{compiler_version} // '';
    my %filter;
    (
        $filter{report_architecture},
        $filter{report_osname},
        $filter{report_osversion},
    ) = split /##/, $aov_selected, 3;
    (
        $filter{config_cc},
        $filter{config_ccversion}
    ) = split /##/, $compiler_version, 2;
    while (my ($k, $v) = each %filter) {
        delete $filter{$k} if ! $v;
    }

    my ($whatnext) = split " ", lc($data->{whatnext} || 'list');
    my $page = $data->{page} || 1;
    $pv_selected = '%'
        if exists $data->{perl_version} && ! $data->{perl_version};

    my $reports;
    if ($whatnext eq 'list') {
        $reports = $self->get_reports_by_filter($pv_selected, $page, \%filter);
    }
    else {
        $reports = $self->get_reports_by_perl_version($pv_selected, \%filter);
    }
    my $count = $self->get_reports_by_filter_count($pv_selected, \%filter);

    return {
        perl_latest       => $perl_latest,
        perl_versions     => $perlversion_list,
        pv_selected       => $pv_selected,
        page_selected     => $page,
        whatnext          => $whatnext,
        arch_os_ver       => $self->get_architecture_os,
        aov_selected      => $aov_selected,
        compiler_versions => $self->get_compilers,
        compiler_version  => $compiler_version,
        reports           => $reports,
        page_count        => $count,
    };
}

sub get_reports_by_perl_version {
    my $self = shift;
    my ($pattern, $raw_filter) = @_;
    ($pattern ||= '%') =~ s/\*/%/g;

    my (%report_filter, %config_filter);
    for my $key (keys %$raw_filter) {
        $key =~ /^report_(.+)/ and $report_filter{$1} = $raw_filter->{$key};
    }
    for my $key (keys %$raw_filter) {
        $key =~ /^config_(.+)/ and $config_filter{"configs.$1"} = $raw_filter->{$key};
    }
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
            %report_filter,
        },
        {
            order_by => [qw/architecture hostname osname osversion/],
        }
    );
    return [ $reports->all() ];
}

sub get_reports_by_filter_count {
    my $self = shift;
    my ($pattern, $raw_filter) = @_;

    ($pattern ||= '%') =~ s/\*/%/g;
    my (%report_filter, %config_filter);
    for my $key (keys %$raw_filter) {
        $key =~ /^report_(.+)/ and $report_filter{$1} = $raw_filter->{$key};
    }
    for my $key (keys %$raw_filter) {
        $key =~ /^config_(.+)/ and $config_filter{"configs.$1"} = $raw_filter->{$key};
    }

    my $count = $self->schema->resultset('Report')->search(
        {
            perl_id => { -like => $pattern },
            %report_filter,
            %config_filter,
        },
        {
            join => 'configs',
            columns  => [qw/id/],
            distinct => 1,
        }
    )->count();
    return int(($count + $self->reports_per_page - 1)/$self->reports_per_page);
}

sub get_reports_by_filter {
    my $self = shift;
    my ($pattern, $page, $raw_filter) = @_;

    ($pattern ||= '%') =~ s/\*/%/g;
    $page ||= 1;

    my (%report_filter, %config_filter);
    for my $key (keys %$raw_filter) {
        $key =~ /^report_(.+)/ and $report_filter{$1} = $raw_filter->{$key};
    }
    for my $key (keys %$raw_filter) {
        $key =~ /^config_(.+)/ and $config_filter{"configs.$1"} = $raw_filter->{$key};
    }

    my $reports = $self->schema->resultset('Report')->search(
        {
            perl_id => { -like => $pattern },
            %report_filter,
            %config_filter
        },
        {
            join     => 'configs',
            columns  => [qw/id architecture osname osversion smoke_date
                            hostname git_describe summary/],
            distinct => 1,
            order_by => { -desc => 'smoke_date' },
            page     => $page,
            rows     => $self->reports_per_page,
        }
    );
    return [$reports->all()];
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
        map $_->arch_os_version_pair, $architecture->all(),
    ];
}

sub get_compilers {
    my $self = shift;
    my $compilers = $self->schema->resultset('Config')->search(
        undef,
        {
            columns  => [qw/cc ccversion/],
            group_by => [qw/cc ccversion/],
            order_by => [qw/cc ccversion/],
        }
    );
    return [
        map $_->c_compiler_pair, $compilers->all()
    ];
}

sub get_perlversion_list {
    my $self = shift;
    my ($pattern) = @_;
    ($pattern ||= '%') =~ s/\*/%/g;

    my $pversions = $self->schema->resultset('Report')->search(
        {
            perl_id => { -like => $pattern }
        },
        {
            columns  => [qw/perl_id/],
            group_by => [qw/perl_id/],
            order_by => {-desc => 'perlversion_float(perl_id)'},
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

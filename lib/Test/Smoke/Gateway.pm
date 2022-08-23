package Test::Smoke::Gateway;
use Moose;

use Date::Parse;
use Digest::MD5;
use Encode qw/encode decode/;
use JSON;
use Params::Validate ':all';
use POSIX qw/strftime/;

has schema => (is => 'ro', required => 1);

has reports_per_page => (
    is      => 'ro',
    isa     => 'Int',
    default => 25
);

my @_binary_data = qw/ log_file out_file manifest_msgs compiler_msgs nonfatal_msgs /;

our $VERSION = '0.10_01';

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

=head2 $gw->api_get_reports_from_id($id, $limit)

Returns a list of report-id's that have an id greater than or equal to C<$id>.

=cut

sub api_get_reports_from_id {
    my $self = shift;
    my ($id, $limit) = validate_pos(
        @_,
        { regex => qr/^[1-9][0-9]*$/, optional => 0 },
        { regex => qr/^[1-9][0-9]*$/, optional => 1 },
    );
    my $reports = $self->schema->resultset('Report')->search(
        { id => { '>=' => $id } },
        {
            order_by => { -asc => 'id' },
            rows     => $limit,
            columns  => [ "id" ],
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

    my @other_data = qw/harness_only harness3opts summary/;
    $report_data->{$_} = delete $data->{$_} for @other_data;

    $report_data->{$_} = encode('utf8', delete $data->{$_}) for @_binary_data;

    my $configs = delete $data->{'configs'};
    return $self->schema->txn_do(
        sub {
            my $r = $self->schema->resultset('Report')->create($report_data);
            $r->discard_changes; # re-fetch for the generated plevel

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

    for my $binary_stored (@_binary_data) {
        $report->$binary_stored(decode('utf8', $report->$binary_stored));
    }
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
    my $perl_latest      = $perlversion_list->[0]{value};
    my $pv_selected      = $data->{selected_perl};
    $pv_selected         = $perl_latest if not $pv_selected or $pv_selected eq "latest";
    $pv_selected         = "%" if $pv_selected eq "all";
    my %filter           = (
        report_architecture        => $data->{selected_arch},
        report_architecture_andnot => $data->{andnotsel_arch},
        report_osname              => $data->{selected_osnm},
        report_osname_andnot       => $data->{andnotsel_osnm},
        report_osversion           => $data->{selected_osvs},
        report_osversion_andnot    => $data->{andnotsel_osvs},
        report_hostname            => $data->{selected_host},
        report_hostname_andnot     => $data->{andnotsel_host},
        report_smoke_branch        => $data->{selected_branch},
        report_smoke_branch_andnot => $data->{andnotsel_branch},
        config_cc                  => $data->{selected_comp},
        config_cc_andnot           => $data->{andnotsel_comp},
        config_ccversion           => $data->{selected_cver},
        config_ccversion_andnot    => $data->{andnotsel_cver},
    );

    while (my ($k, $v) = each %filter) {
        delete $filter{$k} if ! $v;
    }

    # If Perl version is 'latest' (or initial empty) and no other filter is used,
    # only show the latest smoke result per Arch/OS/OSVersion/...
    my ($reports, $count);
    my $page     = $data->{page} || 1;
    if ((not $data->{selected_perl} or $data->{selected_perl} eq "latest")
        and not %filter) {
        $reports = $self->get_reports_by_perl_version($pv_selected,  \%filter);
    } else {
        $reports = $self->get_reports_by_filter($pv_selected, $page, \%filter);
        $count   = $self->get_reports_by_filter_count($pv_selected,  \%filter);
    }

    # Get all the possible values to select from
    my $sel_arch_os_ver = $self->get_architecture_os;
    my $sel_comp_ver    = $self->get_compilers;
    my @items_arch_os_ver;
    my @items_comp_ver;
    foreach my $selitem (@$sel_arch_os_ver) {
        my ($item_arch, $item_os, $item_osver, $item_host) = split /##/, $selitem->{value}, 4;
        push @items_arch_os_ver, {
            arch      => $item_arch,
            os        => $item_os,
            osversion => $item_osver,
            hostname  => $item_host,
        };
    }
    foreach my $selitem (@$sel_comp_ver) {
        my ($item_comp, $item_compver) = split /##/, $selitem->{value}, 2;
        push @items_comp_ver, {
            comp        => $item_comp,
            compversion => $item_compver,
        };
    }

    return {
        perl_latest       => $perl_latest,
        perl_versions     => $perlversion_list,
        pv_selected       => $data->{selected_perl},
        page_selected     => $page,
        reports           => $reports,
        total_count       => $count,
        page_count        => $count ? int(($count + $self->reports_per_page - 1)/$self->reports_per_page) : 1,
        sel_arch_os_ver   => \@items_arch_os_ver,
        sel_comp_ver      => \@items_comp_ver,
        filters           => \%filter,
        branches          => $self->get_branches(),
    };
}

sub latest_only {
    my $self = shift;

    my $reports = $self->schema->resultset('Report');
    my $result = $reports->search(
        {
            plevel => {
                '=' => $reports->search(
                    {
                        hostname     => { '=' => \'me.hostname' },
                    },
                    { alias => 'rh' }
                )->get_column('plevel')->max_rs->as_query,
            },
            smoke_date => {
                '=' => $reports->search(
                    {
                        hostname => { '=' => \'me.hostname' },
                        plevel   => { '=' => \'me.plevel' },
                    },
                    { alias => 'rhp' }
                )->get_column('smoke_date')->max_rs->as_query,
            },
        },
        {
            columns => [qw/
                id architecture hostname osname osversion
                perl_id git_id git_describe plevel smoke_branch
                username smoke_date summary cpu_count cpu_description
            /],
            order_by => [
                { '-desc' => 'smoke_date' },
                { '-desc' => 'plevel' },
                qw/architecture osname osversion hostname/
            ],
        }
    );
    my $latest_plevel = $reports->search()->get_column('plevel')->max();

    return {
        reports       => [ $result->all ],
        latest_plevel => $latest_plevel,
    };
}

sub get_reports_by_perl_version {
    my $self = shift;
    my ($pattern, $raw_filter) = @_;
    ($pattern ||= '%') =~ s/\*/%/g;

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
            $self->get_filter_query_report(\%$raw_filter),
        },
        {
            columns  => [qw/
                id architecture hostname osname osversion
                perl_id git_id git_describe smoke_branch
                username smoke_date summary cpu_count cpu_description
            /],
            order_by => [qw/architecture hostname osname osversion/],
        }
    );
    return [ $reports->all() ];
}

sub get_reports_by_filter_count {
    my $self = shift;
    my ($pattern, $raw_filter) = @_;
    ($pattern ||= '%') =~ s/\*/%/g;

    return $self->schema->resultset('Report')->search(
        {
            perl_id  => { -like => $pattern },
            $self->get_filter_query_report(\%$raw_filter),
            $self->get_filter_query_config(\%$raw_filter),
        },
        {
            join     => 'configs',
            columns  => [qw/id/],
            distinct => 1,
        }
    )->count();
}

sub get_reports_by_filter {
    my $self = shift;
    my ($pattern, $page, $raw_filter) = @_;
    ($pattern ||= '%') =~ s/\*/%/g;
    $page     ||= 1;

    my $reports = $self->schema->resultset('Report')->search(
        {
            perl_id  => { -like => $pattern },
            $self->get_filter_query_report(\%$raw_filter),
            $self->get_filter_query_config(\%$raw_filter),
        },
        {
            join     => 'configs',
            columns  => [qw/id architecture osname osversion smoke_date
                            hostname git_describe smoke_branch summary/],
            distinct => 1,
            order_by => { -desc => 'smoke_date' },
            page     => $page,
            rows     => $self->reports_per_page,
        }
    );
    return [$reports->all()];
}

sub get_filter_query_report {
    my $self = shift;
    my ($raw_filter) = @_;
    my %report_filter;

    for my $key (keys %$raw_filter) {
        next if $key =~ /_andnot$/;
        if ($raw_filter->{$key .'_andnot'}) {
            $key =~ /^report_(.+)/ and $report_filter{$1} = { '!=' => $raw_filter->{$key} };
        } else {
            $key =~ /^report_(.+)/ and $report_filter{$1} = $raw_filter->{$key};
        }
    }
    return %report_filter;
}

sub get_filter_query_config {
    my $self = shift;
    my ($raw_filter) = @_;
    my %config_filter;

    for my $key (keys %$raw_filter) {
        next if $key =~ /_andnot$/;
        if ($raw_filter->{$key .'_andnot'}) {
            $key =~ /^config_(.+)/ and $config_filter{"configs.$1"} = { '!=' => $raw_filter->{$key} };
        } else {
            $key =~ /^config_(.+)/ and $config_filter{"configs.$1"} = $raw_filter->{$key};
        }
    }
    return %config_filter;
}

sub get_architecture_os {
    my $self = shift;
    my $architecture = $self->schema->resultset('Report')->search(
        undef,
        {
            columns  => [qw/architecture osname osversion hostname/],
            group_by => [qw/architecture osname osversion hostname/],
            order_by => [qw/architecture osname osversion hostname/],
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

    my $pversions = [
        sort {
            _pversion($b->perl_id) <=> _pversion($a->perl_id)
        } $self->schema->resultset('Report')->search(
            {
                perl_id => { -like => $pattern }
            },
            {
                columns  => [qw/perl_id/],
                group_by => [qw/perl_id/],
#                order_by => {-desc => 'perlversion_float(perl_id)'},
            }
        )
    ];
    return [
        map {
            my $record = {
                value => $_->perl_id,
                label => $_->perl_id,
            };
        } @$pversions
    ];
}

=head2 $gw->get_failures_by_version

    select distinct f.test       as test
                  , rp.id        as report_id
                  , rp.perl_id   as perl_id
                  , rp.osname    as os_name
                  , rp.osversion as os_version
               from failure f
               join failures_for_env fe on fe.failure_id = f.id
               join result r on fe.result_id = r.id
               join config c on r.config_id = c.id
               join report rp on c.report_id = rp.id
                    ;

=cut

sub get_failures_by_version {
    my $self = shift;

    my $pversions = $self->get_perlversion_list();
    my $pversion_in = [ grep { defined } map { $_->{value} } @{$pversions}[0..4] ];

    my $failures = $self->schema->resultset('Failure')->search(
        {
            'status'         => {like => 'FAILED%'},
            'report.perl_id' => $pversion_in,
        },
        {
            join => {failures_for_env => {result => {config => 'report'}}},
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            columns => {
                test       => 'test',
                report_id  => 'report.id',
                perl_id    => 'report.perl_id',
                os_name    => 'report.osname',
                os_version => 'report.osversion',
            },
            distinct => 1,
        }
    );

    return $failures;
}

=head2 $gw->get_failures_for_pversion

    select distinct f.test           as test
                  , rp.id            as report_id
                  , rp.perl_id       as perl_id
                  , rp.git_subscribe as git_id
                  , rp.osname        as os_name
                  , rp.osversion     as os_version
               from failure f
               join failures_for_env fe on fe.failure_id = f.id
               join result r on fe.result_id = r.id
               join config c on r.config_id = c.id
               join report rp on c.report_id = rp.id
                    ;

=cut

sub get_failures_for_pversion {
    my $self = shift;
    my %args = @_;

    my $pversions = $self->get_perlversion_list();
    my $pversion_in = [ grep { defined } map { $_->{value} } @{$pversions}[0..4] ];

    my $failures = $self->schema->resultset('Failure')->search(
        {
            'status' => {like => 'FAILED%'},
            'test'   => $args{test},
            ($args{pversion}
                ? ('report.perl_id' => $args{pversion})
                : ('report.perl_id' => $pversion_in)
            ),
        },
        {
            join => {failures_for_env => {result => {config => 'report'}}},
            result_class => 'DBIx::Class::ResultClass::HashRefInflator',
            columns => {
                test       => 'test',
                report_id  => 'report.id',
                perl_id    => 'report.perl_id',
                git_id     => 'report.git_describe',
                os_name    => 'report.osname',
                os_version => 'report.osversion',
            },
            distinct => 1,
        }
    );

    return $failures;
}

sub failures_matrix {
    my $self = shift;
    my $fails = $self->get_failures_by_version();

    # Create the matrix...
    my (%failing_test_count, %pversions);
    for my $fail ($fails->all) {
        $failing_test_count{ $fail->{test} }++;
        push @{
            $pversions{$fail->{perl_id}}{$fail->{test}}
        }, "$fail->{os_name} - $fail->{os_version}";
    }

    my %matrix = map {
        ( sprintf("%04d%s", $failing_test_count{$_}, $_) => [ $_ ] )
    } sort {
        $failing_test_count{$b} <=> $failing_test_count{$a}
    } keys %failing_test_count;
    $matrix{'?'} = [ '&nbsp;' ];

    my @reverse_sorted_pversion = sort {
        _pversion($b) cmp _pversion($a)
    } keys %pversions;
    for my $pversion (@reverse_sorted_pversion) {
        for my $index (keys %matrix) {
            if ($index eq '?') {
                push @{ $matrix{'?'} }, $pversion;
            }
            else {
                my $test = $matrix{$index}[0];
                my $count = exists $pversions{$pversion}{$test}
                    ? 0 + @{$pversions{$pversion}{$test}}
                    : '';
                my %oses = map { ($_ => undef) } @{$pversions{$pversion}{$test}};
                my $os = join(';', sort keys %oses);

                push @{$matrix{$index}}, {cnt => $count, alt => $os};
            }
        }
    }
    my @matrix;
    for my $index (sort {$b cmp $a} keys %matrix) { push @matrix, $matrix{$index} }

    return \@matrix;
}

sub failures_submatrix {
    my $self = shift;

    my $fails = $self->get_failures_for_pversion(@_);
    my @reports = map {
        my $copy = $_;
        $copy->{git_sha} = $copy->{git_id} =~ /-g(?<sha>[0-9a-f]+)$/
            ? $+{sha} : '';
        $copy
    } sort {
           _pversion($b->{perl_id})   cmp _pversion($a->{perl_id})
        || _gversion($b->{git_id})    cmp _gversion($a->{git_id})
        || $a->{report_id}            <=> $b->{report_id}
    } $fails->all;

    return \@reports;
}

sub get_branches {
    my $self = shift;
    my $branches = $self->schema->resultset('Report')->search_rs(
        { },
        {
            select   => ['smoke_branch'],
            distinct => 1,
        }
    );
    return [ sort map { $_->smoke_branch } $branches->all ];
}

# make a float representation of a perl-version.
sub _pversion {
    my ($perl_id) = @_;
    return $perl_id if $perl_id =~ /\.\?/;

    my $rc = $perl_id =~ s/(?<rc>-RC[0-9]+)// ? $+{rc} : '';
    use version;
    return version->parse($perl_id)->numify . $rc;
}

sub _gversion {
    my ($git_describe) = @_;
    if ($git_describe =~ /v(?<perl_id>.+)-(?<commits>[0-9]+)-g[0-9a-f]+$/) {
        my $pversion = _pversion($+{perl_id});
        return sprintf("%.06f-%06d", $pversion, $+{commits});
    }
    return $git_describe;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 STUFF

(c) MMXI - Abe Timmerman <abeltje@cpan.org>

=cut

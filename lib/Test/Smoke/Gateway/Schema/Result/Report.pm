use utf8;
package Test::Smoke::Gateway::Schema::Result::Report;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Test::Smoke::Gateway::Schema::Result::Report

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<report>

=cut

__PACKAGE__->table("report");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'report_id_seq'

=head2 sconfig_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 duration

  data_type: 'integer'
  is_nullable: 1

=head2 config_count

  data_type: 'integer'
  is_nullable: 1

=head2 reporter

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 reporter_version

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_perl

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_revision

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_version

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoker_version

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 smoke_date

  data_type: 'timestamp with time zone'
  is_nullable: 0

=head2 perl_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 git_id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 git_describe

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 applied_patches

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 hostname

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 architecture

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 osname

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 osversion

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 cpu_count

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 cpu_description

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 username

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 test_jobs

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lc_all

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 lang

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 user_note

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 manifest_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 compiler_msgs

  data_type: 'bytea'
  is_nullable: 1

=head2 skipped_tests

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 log_file

  data_type: 'bytea'
  is_nullable: 1

=head2 out_file

  data_type: 'bytea'
  is_nullable: 1

=head2 harness_only

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 harness3opts

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 summary

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 smoke_branch

  data_type: 'text'
  default_value: 'blead'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 nonfatal_msgs

  data_type: 'bytea'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "report_id_seq",
  },
  "sconfig_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "duration",
  { data_type => "integer", is_nullable => 1 },
  "config_count",
  { data_type => "integer", is_nullable => 1 },
  "reporter",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "reporter_version",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_perl",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_revision",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_version",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoker_version",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "smoke_date",
  { data_type => "timestamp with time zone", is_nullable => 0 },
  "perl_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "git_id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "git_describe",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "applied_patches",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "hostname",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "architecture",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "osname",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "osversion",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "cpu_count",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "cpu_description",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "username",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "test_jobs",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lc_all",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "lang",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "user_note",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "manifest_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "compiler_msgs",
  { data_type => "bytea", is_nullable => 1 },
  "skipped_tests",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "log_file",
  { data_type => "bytea", is_nullable => 1 },
  "out_file",
  { data_type => "bytea", is_nullable => 1 },
  "harness_only",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "harness3opts",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "summary",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "smoke_branch",
  {
    data_type     => "text",
    default_value => "blead",
    is_nullable   => 1,
    original      => { data_type => "varchar" },
  },
  "nonfatal_msgs",
  { data_type => "bytea", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<report_git_id_key>

=over 4

=item * L</git_id>

=item * L</smoke_date>

=item * L</duration>

=item * L</hostname>

=item * L</architecture>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "report_git_id_key",
  ["git_id", "smoke_date", "duration", "hostname", "architecture"],
);

=head1 RELATIONS

=head2 configs

Type: has_many

Related object: L<Test::Smoke::Gateway::Schema::Result::Config>

=cut

__PACKAGE__->has_many(
  "configs",
  "Test::Smoke::Gateway::Schema::Result::Config",
  { "foreign.report_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 sconfig

Type: belongs_to

Related object: L<Test::Smoke::Gateway::Schema::Result::SmokeConfig>

=cut

__PACKAGE__->belongs_to(
  "sconfig",
  "Test::Smoke::Gateway::Schema::Result::SmokeConfig",
  { id => "sconfig_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2014-08-23 19:21:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Thw8Cig5H/5VPYgkuGNroA

sub arch_os_version_key {
    my $self = shift;
    return join( "##", $self->architecture, $self->osname, $self->osversion, $self->hostname);
}

sub arch_os_version_label {
    my $self = shift;
    return join( " - ", $self->architecture, $self->osname, $self->osversion, $self->hostname);
}

sub arch_os_version_pair {
    my $self = shift;
    return {value => $self->arch_os_version_key, label => $self->arch_os_version_label};
}

my %io_env_order_map = (
    minitest => 1,
    stdio    => 2,
    perlio   => 3,
    locale   => 4,
);
my $max_io_envs = scalar(keys %io_env_order_map);

sub title {
    my $self = shift;

    return join(
        " ",
        "Smoke",
        $self->git_describe,
        $self->summary,
        $self->osname,
        $self->osversion,
        $self->cpu_description,
        $self->cpu_count
    );
}

sub list_title {
    my $self = shift;

    return join(
        " ",
        $self->git_describe,
        $self->osname,
        $self->osversion,
        $self->cpu_description,
        $self->cpu_count
    );
}

sub c_compilers {
    my $self = shift;

    my %c_compiler_seen;
    my $i = 1;
    for my $config ($self->configs) {
        $c_compiler_seen{$config->c_compiler_key} //= {
            index     => $i++,
            key       => $config->c_compiler_key,
            cc        => $config->cc,
            ccversion => $config->ccversion,
        };
    }
    return [
        sort {
            $a->{index} <=> $b->{index}
        } values %c_compiler_seen
    ];
}

sub matrix {
    my $self = shift;

    my %c_compilers = map {
        $_->{key} => $_
    } @{$self->c_compilers};

    my (%matrix, %cfg_order, %io_env_seen);
    my $o = 0;
    for my $config ($self->configs) {
        for my $result ($config->results) {
            my $cc_index = $c_compilers{$config->c_compiler_key}{index};

            $matrix{$cc_index}{$config->debugging}{$config->arguments}{$result->io_env} =
                $result->summary;
            $io_env_seen{$result->io_env} = $result->locale;
        }
        $cfg_order{$config->arguments} //= $o++;
    }

    my @io_env_in_order = sort {
        $io_env_order_map{$a} <=> $io_env_order_map{$b}
    } keys %io_env_seen;

    my @cfg_in_order = sort {
        $cfg_order{$a} <=> $cfg_order{$b}
    } keys %cfg_order;

    my @matrix;
    for my $cc (sort { $a->{index} <=> $b->{index} } values %c_compilers) {
        my $cc_index = $cc->{index};
        for my $cfg (@cfg_in_order) {
            my @line;
            for my $debugging (qw/ N D /) {
                for my $io_env (@io_env_in_order) {
                    push(
                        @line,
                        $matrix{$cc_index}{$debugging}{$cfg}{$io_env} || '-'
                    );
                }
            }
            while (@line < 8) { push @line, " " }
            my $mline = join("  ", @line);
            push @matrix, "$mline  $cfg (\*$cc_index)";
        }
    }
    my @legend = $self->matrix_legend(
        [
            map { $io_env_seen{$_} ? "$_:$io_env_seen{$_}" : $_ }
                @io_env_in_order
        ]
    );
    return @matrix, @legend;
}

sub matrix_legend {
    my $self = shift;
    my ($io_envs) = @_;

    my @legend = (
        (map "$_ DEBUGGING", reverse @$io_envs),
        (reverse @$io_envs)
    );
    my $first_line = join("  ", ("|") x @legend);

    my $length = (3 * 2 * $max_io_envs) - 2;
    for my $i (0 .. $#legend) {
        my $bar_count = scalar(@legend) - $i;
        my $prefix = join("  ", ("|") x $bar_count);
        $prefix =~ s/(.*)\|$/$1+/;
        my $dash_count = $length - length($prefix);
        $prefix .= "-" x $dash_count;
        $legend[$i] = "$prefix  $legend[$i]"
    }
    unshift @legend, $first_line;
    return @legend;
}

sub test_failures {
    my $self = shift;
    return $self->group_tests_by_status('FAILED');
}

sub test_todo_passed {
    my $self = shift;
    return $self->group_tests_by_status('PASSED');
}

sub group_tests_by_status {
    my $self = shift;
    my ($group_status) = @_;

    use Data::Dumper; $Data::Dumper::Indent = 1; $Data::Dumper::Sortkeys = 1;

    my %c_compilers = map {
        $_->{key} => $_
    } @{$self->c_compilers};

    my (%tests);
    my $max_name_length = 0;
    for my $config ($self->configs) {
        for my $result ($config->results) {
            for my $io_env ($result->failures_for_env) {
                for my $test ($io_env->failure) {
                    next if $test->status ne $group_status;

                    $max_name_length = length($test->test)
                        if length($test->test) > $max_name_length;

                    my $key = $test->test . $test->extra;
                    push(
                        @{$tests{$key}{$config->full_arguments}{test}}, {
                            test_env => $result->test_env,
                            test     => $test,
                        }
                    );
                }
            }
        }
    }
    my @grouped_tests;
    for my $group (values %tests) {
        push @grouped_tests, {test => undef, configs => [ ]};
        for my $cfg (keys %$group) {
            push @{ $grouped_tests[-1]->{configs} }, {
                arguments => $cfg,
                io_envs   => join("/", map $_->{test_env}, @{ $group->{$cfg}{test} })
            };
            $grouped_tests[-1]{test} //= $group->{$cfg}{test}[0]{test};
        }
    }
    return \@grouped_tests;
}

sub plevel {
    my $self = shift;

    (my $git_describe  = $self->git_describe) =~ s{^v}{};
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

sub duration_in_hhmm {
    my $self = shift;
    return time_in_hhmm($self->duration);
}

sub average_in_hhmm {
    my $self = shift;
    return time_in_hhmm($self->duration/$self->config_count);
}

sub time_in_hhmm {
    my $diff = shift;

    # Only show decimal point for diffs < 5 minutes
    my $digits = $diff =~ /\./ ? $diff < 5*60 ? 3 : 0 : 0;
    my $days = int( $diff / (24*60*60) );
    $diff -= 24*60*60 * $days;
    my $hour = int( $diff / (60*60) );
    $diff -= 60*60 * $hour;
    my $mins = int( $diff / 60 );
    $diff -=  60 * $mins;
    $diff = sprintf "%.${digits}f", $diff;

    my @parts;
    $days and push @parts, sprintf "%d day%s",   $days, $days == 1 ? "" : 's';
    $hour and push @parts, sprintf "%d hour%s",  $hour, $hour == 1 ? "" : 's';
    $mins and push @parts, sprintf "%d minute%s",$mins, $mins == 1 ? "" : 's';
    $diff && !$days && !$hour and push @parts, "$diff seconds";

    return join " ", @parts;
}

1;

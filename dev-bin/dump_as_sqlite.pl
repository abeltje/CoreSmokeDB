#! /usr/bin/perl -w
use strict;
use Data::Dumper; $Data::Dumper::Indent = 1; $Data::Dumper::Sortkeys = 1;
$|++;

use Hash::Util 'lock_hash';
use Scalar::Util 'blessed';

use Test::Smoke::Gateway::Schema;

my %option = (
    sqlite_name => 'tsgateway.sqlite',
    postgresql  => {
        dsn => 'dbi:Pg:dbname=tsgateway',
        usr => 'abeltje',
    },
);
use Getopt::Long;
GetOptions(
    \%option => qw/
        sqlite_name|s=s
        postgresql|p=s%
        count|c=i
    /
);
lock_hash(%option);
if (-f $option{sqlite_name}) {
    printf "Remove %s: %s\n", $option{sqlite_name}, unlink $option{sqlite_name};
}

my $sqlite = Test::Smoke::Gateway::Schema->connect(
   "dbi:SQLite:dbname=$option{sqlite_name}", '', '',
   { ignore_version => 1 }
);
$sqlite->deploy();

my $pg = Test::Smoke::Gateway::Schema->connect(
    @{$option{postgresql}}{qw/dsn usr pwd/}
);

copy_reports($pg, $sqlite, $option{count});

sub copy_reports {
    my ($src, $dst, $count) = @_;

    my $dir = $count < 0 ? '-desc' : '-asc';
    my %rows = $count ? (rows => abs($count)) : ();

    my $rs = $src->resultset('Report')->search(
        {},
        { order_by => {$dir => 'id'}, %rows }
    );
    printf "# of reports: %s\n", $rs->count;
    while (my $row = $rs->next) {
        my %data = $row->get_inflated_columns;
        $dst->resultset('Report')->create(\%data);
        printf "#configs: %s\n", $row->configs->count;

        for my $config ($row->configs->all()) {
            my %cdata = $config->get_inflated_columns;
            $dst->resultset('Config')->create({%cdata});

            for my  $result ($config->results->all()) {
                my %rdata = $result->get_inflated_columns;
                $dst->resultset('Result')->create({%rdata});

                for my $ffe ($result->failures_for_env->all()) {
                    my $failure = $dst->resultset('Failure')->find_or_create(
                        {$ffe->failure->get_inflated_columns},
                        {key => 'failure_test_key'}
                    );
                    $dst->resultset('FailureForEnv')->create(
                        { $ffe->get_inflated_columns }
                    );
                }
            }
        }
        printf "Inserted id: %s\n", $data{id};
    }
}

sub copy_data {
}

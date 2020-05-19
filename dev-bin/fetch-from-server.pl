#! /usr/bin/perl -w
use strict;
use FindBin;

use lib "$FindBin::Bin/../local/lib/perl5";
use lib "$FindBin::Bin/../lib";

use Data::Dumper; $Data::Dumper::Indent = 1; $Data::Dumper::Sortkeys = 1;
$|++;

use Test::Smoke::Gateway;
use Test::Smoke::Gateway::Schema;
use HTTP::Tiny;
use URI;
use Date::Parse;
use JSON::PP;

my %option = (
    sqlite_name => 'CoreSmokeDB.sqlite',
    url         => 'http://perl5.test-smoke.org/',
);
use Getopt::Long;
GetOptions(
    \%option => qw/
        sqlite_name|s=s
        url|u=s
        date_from|d=s
    /
);
if (!$option{date_from}) {
    die <<"EOH";
Usage: $0 --date_from <ISO8601-ish>

This script uses the CoreSmokeDB production API to retrieve reports
and put them in a SQLite database that can be used for tsgateway.

  --url|-u <url>             : Where is that api? ($option{url})
  --sqlite_name|-s <db-name> : Where to store? ($option{sqlite_name})
  --date_from|-d <iso8601>   : Whence to retrieve
EOH
}

if (-f $option{sqlite_name}) {
    printf "Remove %s: %s\n", $option{sqlite_name}, unlink $option{sqlite_name};
}

my $sqlite = Test::Smoke::Gateway::Schema->connect(
   "dbi:SQLite:dbname=$option{sqlite_name}", '', '',
   { ignore_version => 1 }
);
$sqlite->deploy();

my $gw = Test::Smoke::Gateway->new(schema => $sqlite);

my $csdb = URI->new($option{url});
my $ua = HTTP::Tiny->new(agent => 'CoreSmokeDB/0.42');

my $epoch = str2time($option{date_from});
(my $new_since = $csdb->clone)->path("/api/reports_from_date/$epoch");
my $response = $ua->get( $new_since );

my $report_ids = decode_json($response->{content});
# my $report_ids = [ 113299 ];

printf "Got %u report-ids from server!\n", scalar(@$report_ids);

for my $report_id (@$report_ids) {
    print "Fetch report: $report_id";
    (my $report_data = $csdb->clone)->path("/api/report_data/$report_id");
    my $response = $ua->get( $report_data );
    print "\n";

    my $report = fix_report( decode_json($response->{content}) );
#print Dumper($report) and last;
    my $host = $report->{sysinfo}{hostname};
    my $id = $gw->post_report($report);
    print "Saved report $report_id as @{[$id->id]}, $host\n";
}

sub fix_report {
    my $report = shift;

    my @as_array_fields = qw(
        applied_patches
        compiler_msgs
        manifest_msgs
        nonfatal_msgs
        skipped_tests
    );
    for my $as_array (@as_array_fields) {
        next if ref($report->{$as_array});
        $report->{$as_array} = [ split(/\n/, $report->{$as_array}) ];
    };

    my @sysinfo_fields = qw(
        architecture
        config_count
        cpu_count
        cpu_description
        duration
        git_describe
        git_id
        hostname
        lang
        lc_all
        osname
        osversion
        perl_id
        reporter
        reporter_version
        smoke_branch
        smoke_date
        smoke_perl
        smoke_revision
        smoke_version
        smoker_version
        test_jobs
        user_note
        username
    );
    for my $sif (@sysinfo_fields) {
        $report->{sysinfo}{$sif} = delete($report->{$sif});
    }

    delete($report->{$_}) for qw(id sconfig_id);
    for my $config (@{ $report->{configs} }) {
        delete($config->{$_}) for qw(id report_id);
        for my $result (@{ $config->{results} }) {
            delete($result->{$_}) for qw(id config_id);
            for my $failure (@{ $result->{failures} }) {
                delete($failure->{$_}) for qw(id);
                $failure->{extra} = [ split(/\n/, $failure->{extra}) ];
            }
        }
    }

    return $report;
}


#! perl -w
use strict;
use lib 'local/lib/perl5';
use Test::More;
use Test::DBIC::SQLite;

use Test::Smoke::Gateway;

my $tester = Test::DBIC::SQLite->new(
    schema_class     => 'Perl5::CoreSmokeDB::Schema',
    dbi_connect_info => "t/test-500.sqlite",
);
my $db = $tester->connect_dbic_ok();

my $gw = Test::Smoke::Gateway->new(schema => $db);
isa_ok($gw, 'Test::Smoke::Gateway');

my $fails = $gw->get_failures_by_version();

is(scalar($fails->all), 884, "Count fails in matrix")
    or diag("Number of fails: ", scalar($fails->all));

$db->storage->disconnect();

done_testing();

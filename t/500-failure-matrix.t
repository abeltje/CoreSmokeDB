#! perl -w
use strict;
use Test::More;
use Test::DBIC::SQLite;

use Test::Smoke::Gateway;

my $db = connect_dbic_sqlite_ok('Test::Smoke::Gateway::Schema', 't/test.sqlite');

my $gw = Test::Smoke::Gateway->new(schema => $db);
isa_ok($gw, 'Test::Smoke::Gateway');

my $fails = $gw->get_failures_by_version();

note(explain([$fails->all]));

done_testing();

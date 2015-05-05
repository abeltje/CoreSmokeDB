#! perl -w
use strict;

use Test::More;

use Test::Smoke::Gateway;
use Test::Smoke::Gateway::Schema;

pass("Loaded Test::Smoke::Gateway");
pass("Loaded Test::Smoke::Gateway::Schema");

my $schema = Test::Smoke::Gateway::Schema->connect(
    'dbi:SQLite:dbname=:memory:', undef, undef,
    {no_version_check => 1}
);
isa_ok($schema, 'Test::Smoke::Gateway::Schema');
$schema->deploy;

my $gw = Test::Smoke::Gateway->new(schema => $schema);
isa_ok($gw, 'Test::Smoke::Gateway');

done_testing();

#! perl -w
use strict;
use autodie;
use JSON::PP;

use Test::More;
use Test::DBIC::SQLite;

use Test::Smoke::Gateway;

pass("Loaded Test::Smoke::Gateway");
pass("Loaded Test::Smoke::Gateway::Schema");

my $schema = connect_dbic_sqlite_ok('Test::Smoke::Gateway::Schema');

my $gw = Test::Smoke::Gateway->new(schema => $schema);
isa_ok($gw, 'Test::Smoke::Gateway');
for my $os (qw(mac ubuntu)) {
    my $file = sprintf("t/data/mktest-%s.jsn", $os);
    open my $fh, '<', $file;
    my $data = decode_json(do {local $/; <$fh>}, {utf8 => 1});

    note(explain($data));

    my $rid = $gw->post_report($data);
    isa_ok($rid, "Test::Smoke::Gateway::Schema::Result::Report");
}

done_testing();

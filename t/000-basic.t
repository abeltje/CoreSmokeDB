#! perl -w
use strict;
use lib 't/lib';
use autodie;
use JSON;

use Test::More;
use Test::DBIC::Pg;
use GitDescribeAsPlevel;

use Test::Smoke::Gateway;

pass("Loaded Test::Smoke::Gateway");
pass("Loaded Test::Smoke::Gateway::Schema");

my $tester = Test::DBIC::Pg->new(
    schema_class    => 'Test::Smoke::Gateway::Schema',
    connect_info    => {
        options => { pg_enable_utf8 => 1 },
    },
    pre_deploy_hook => \&pre_deploy_hook,
);
my $schema = $tester->connect_dbic_ok();

my $gw = Test::Smoke::Gateway->new(schema => $schema);
isa_ok($gw, 'Test::Smoke::Gateway');
for my $os (qw(mac ubuntu)) {
    my $file = sprintf("t/data/mktest-%s.jsn", $os);
    open my $fh, '<:bytes', $file;
    my $data = from_json(do {local $/; <$fh>}, {utf8 => 0});

    note(explain($data));

    my $rid = $gw->post_report($data);
    isa_ok($rid, "Test::Smoke::Gateway::Schema::Result::Report");
}

$schema->storage->disconnect();
$tester->drop_dbic_ok();

done_testing();

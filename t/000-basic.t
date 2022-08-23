#! perl -w
use strict;
use autodie;
use JSON;

use Test::More;
use Test::DBIC::SQLite;

use Test::Smoke::Gateway;

pass("Loaded Test::Smoke::Gateway");
pass("Loaded Test::Smoke::Gateway::Schema");

my $tester = Test::DBIC::SQLite->new(
    schema_class => 'Test::Smoke::Gateway::Schema',
);
my $schema = $tester->connect_dbic_ok();

my $dbh = $schema->storage->dbh;
{
    my $git_describe = 'v5.37.2-263-g74fb05814a';
    my $plevel = $dbh->selectall_arrayref(
        "SELECT git_describe_as_plevel(?)",
        undef,
        $git_describe
    );
    is(
        $plevel->[0][0],
        '5.037002zzz263',
        "Check result of git_describe_as_plevel($git_describe)"
    ) or diag(explain($plevel));

    $git_describe = 'v5.34.0-RC1-8-gf6e15d1844';
    $plevel = $dbh->selectall_arrayref(
        "SELECT git_describe_as_plevel(?)",
        undef,
        $git_describe
    );
    is(
        $plevel->[0][0],
        '5.034000RC1008',
        "Check result of git_describe_as_plevel($git_describe)"
    ) or diag(explain($plevel));
}

my $gw = Test::Smoke::Gateway->new(schema => $schema);
isa_ok($gw, 'Test::Smoke::Gateway');
for my $os (qw(mac ubuntu)) {
    my $file = sprintf("t/data/mktest-%s.jsn", $os);
    open my $fh, '<:bytes', $file;
    my $data = from_json(do {local $/; <$fh>}, {utf8 => 1});

#    note(explain($data));

    my $rid = $gw->post_report($data);
    isa_ok($rid, "Test::Smoke::Gateway::Schema::Result::Report");

    my $report = $schema->resultset("Report")->find(
        { id => $rid->id },
        { columns => [qw/plevel git_describe id/] }
    );

    is(
        $report->plevel,
        $rid->plevel,
        "Check result of generated plevel field " . $rid->plevel
    ) or diag(explain({$report->get_inflated_columns}));
}

$schema->storage->disconnect();
$tester->drop_dbic_ok();

done_testing();

#! perl -w
use strict;
use lib 't/lib';

use Test::More;
use Test::Warnings;
use Test::DBIC::Pg;
use GitDescribeAsPlevel;

my $tester = Test::DBIC::Pg->new(
    schema_class    => 'Test::Smoke::Gateway::Schema',
    connect_info    => {
        options => { pg_enable_utf8 => 1 },
    },
    pre_deploy_hook => \&pre_deploy_hook,
);
{
    note("Check custom methods on Test::Smoke::Gateway::Schema::Result::Result");

    my $db = $tester->connect_dbic_ok();

    my $r = $db->resultset('Report')->create(
        {
            smoke_date      => '2016-02-29T01:02:04Z',
            perl_id         => '5.25.2',
            git_id          => '3df91f1a10601c50feeed86614da0d5be5b1ac59',
            git_describe    => 'v5.25.2-194-g3df91f1',
            hostname        => 'deimos',
            architecture    => 'amd64',
            osname          => 'netbsd',
            osversion       => '5.1.2',
            summary         => 'FAIL (X)',
        }
    );
    isa_ok($r, 'Test::Smoke::Gateway::Schema::Result::Report');

    my $c = $r->create_related(
        configs => {
            arguments => '', # default -des
            debugging => 'D',
            cc => 'clang',
            ccversion => '4.2.1 Compatible Clang 3.5.0 (trunk)',
        }
    );
    isa_ok($c, 'Test::Smoke::Gateway::Schema::Result::Config');

    my $r1 = $c->create_related(
        results => {
            io_env => 'perlio',
            summary => 'X',
        }
    );
    isa_ok($r1, 'Test::Smoke::Gateway::Schema::Result::Result');
    is($r1->test_env, 'perlio', "result->test_env()");

    my $r2 = $c->create_related(
        results => {
            io_env => 'locale',
            locale => 'nl_NL.UTF-8',
            summary => 'O',
        }
    );
    isa_ok($r2, 'Test::Smoke::Gateway::Schema::Result::Result');
    is($r2->test_env, 'locale:nl_NL.UTF-8', "result->test_env()");

    $db->storage->disconnect();
}

$tester->drop_dbic_ok();

done_testing();

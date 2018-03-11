#! perl -w
use strict;

use Test::More;
use Test::NoWarnings ();
use Test::DBIC::SQLite;

{
    note("Check custom methods on Test::Smoke::Gateway::Schema::Result::Config");
    my $db = connect_dbic_sqlite_ok('Test::Smoke::Gateway::Schema');

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

    is($c->c_compiler_key, 'clang##4.2.1 Compatible Clang 3.5.0 (trunk)', 'config->c_compiler_key');
    is(
        $c->c_compiler_label,
        'clang - 4.2.1 Compatible Clang 3.5.0 (trunk)',
        'config->c_compiler_label'
    );
    is_deeply(
        $c->c_compiler_pair,
        {
            value => 'clang##4.2.1 Compatible Clang 3.5.0 (trunk)',
            label => 'clang - 4.2.1 Compatible Clang 3.5.0 (trunk)',
        },
        'config->c_compiler_pair'
    );
    is(
        $c->full_arguments,
        ' DEBUGGING',
        'config->full_arguments()'
    );
}

Test::NoWarnings::had_no_warnings();
$Test::NoWarnings::do_end_test = 0;
done_testing();

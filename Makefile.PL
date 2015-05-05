# perl
use warnings;
use strict;

use ExtUtils::MakeMaker;

my $mmver = eval "ExtUtils::MakeMaker->VERSION";
my $test_requires = (
    $mmver >= 5.5503
        ? $mmver >= 6.64
            ? 'TEST_REQUIRES'
            : "BUILD_REQUIRES"
        : 'PREREQ_PM'
);

my %TestRequires = (
    'Test::Simple'     => 0.88,
    'Test::NoWarnings' => 0,
    'DBD::SQLite'      => 0,
);

WriteMakefile(
    NAME          => 'Test::Smoke::Gateway',
    VERSION_FROM  => 'lib/Test/Smoke/Gateway.pm',
    AUTHOR        => 'Abe Timmerman <abeltje@cpan.org>, '
                   . 'H.Merijn Brand <h.m.brand@xs4all.nl>',
    ABSTRACT_FROM => 'lib/Test/Smoke/Gateway.pm',

    PREREQ_PM => {
        'DBI'                         => 0,
        'DBD::Pg'                     => 0,
        'DBIx::Class'                 => 0,
        'DBIX::Class::Schema::Loader' => 0,
        'Dancer::Plugin::DBIC'        => 0,
        'Dancer'                      => 0,
        'JSON::PP'                    => 0,
        'Template'                    => 2,
        'Digest::MD5'                 => 0,
        ($test_requires eq 'PREREQ_PM'
            ? %TestRequires
            : ()
        ),
    },
    ($test_requires ne 'PREREQ_PM'
        ? ($test_requires => \%TestRequires)
        : ()
    ),
);

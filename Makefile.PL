# perl
use warnings;
use strict;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME          => 'Test::Smoke::Gateway',
    VERSION_FROM  => 'lib/Test/Smoke/Gateway.pm',
    AUTHOR        => 'Abe Timmerman <abeltje@cpan.org>, '
                   . 'H.Merijn Brand <h.m.brand@xs4all.nl>',
    ABSTRACT_FROM => 'lib/Test/Smoke/Gateway.pm',

    PREREQ_PM     => {
        'DBIx::Class' => 0,
        'Dancer'      => 0,
        'JSON::PP'    => 0,
        'Template'    => 2,
        'Digest::MD5' => 0,
    },
);

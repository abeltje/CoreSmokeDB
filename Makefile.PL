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
);

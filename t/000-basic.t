#! perl
use warnings;
use strict;

use Test::More;

use Test::Smoke::Gateway;
pass("Loaded Test::Smoke::Gateway");

my $gw = Test::Smoke::Gateway->new;
isa_ok $gw, 'Test::Smoke::Gateway';

done_testing;

#! /usr/bin/perl
use warnings;
use strict;

use DBIx::Class::Schema::Loader 'make_schema_at';

make_schema_at(
   'Test::Smoke::Gateway::Schema',
   {
       debug                   => 1,
       dump_directory          => './lib',
       overwrite_modifications => 0,
   },
   [
       'dbi:Pg:host=fidodbmaster;database=tsgateway',
       'tsgateway',
       'TSg4t3w4y',
   ],
);

#! /usr/bin/perl
use warnings;
use strict;

use DBIx::Class::Schema::Loader 'make_schema_at';

make_schema_at(
   'Test::Smoke::Gateway::Schema',
   {
       debug                   => 1,
       dump_directory          => './lib',
       overwrite_modifications => 1,
   },
   [
       'dbi:SQLite:dbname=/data/apache/tsmbgw/tsmbgw.db',
   ],
);

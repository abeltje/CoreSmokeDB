#! /usr/bin/perl -w
use strict;
use autodie;
use Data::Dumper;

use lib '../lib';
use lib 'lib';

use JSON;

use Test::Smoke::Gateway::Schema;
use Test::Smoke::Gateway;

use Getopt::Long;
my %option = (
    db => {
        dsn => 'dbi:Pg:host=fidodbmaster;dbname=tsgateway',
        usr => 'tsgateway',
        pwd => 'foobar',
    },
    file => 'mktest-utf8.jsn',
);
my %db = %{$option{db}};
my $db = Test::Smoke::Gateway::Schema->connect($db{dsn}, $db{usr}, $db{pwd}, {pg_enable_utf8 => 1});

my $result = $db->resultset('TsgatewayConfig')->search(
    {name => {'in' => ['dbversion']}}
);
printf "%20s - %s\n", $_->name, $_->value for $result->all;

open my $fh, '<:encoding(UTF-8)', $option{file};
my $json = do {local $/; <$fh>};
close $fh;

my $gw = Test::Smoke::Gateway->new(schema => $db);
my $data = from_json($json);
#print Data::Dumper->new([$data])->Sortkeys(1)->Indent(1)->Dump;
print $gw->post_report($data);

#!/usr/bin/perl -w
use strict;

use Cwd qw(abs_path);
use Daemon::Control;
use File::Basename;
use Getopt::Long qw/:config pass_through/;

my ($user, $gid) = (getpwuid($<))[0,3];
my $group = getgrgid($gid);

my %option = (
    port        => 5000,
    environment => 'development',
    appdir      => abs_path(dirname($0) . '/..'),
    appname     => 'CoreSmokeDB',
);
GetOptions(
    \%option => qw/
        port|p=i
        environment|E=s
        appdir|d=s
        appname|n=s
    /
) or die "Problem with GetOptions\n";

$option{appdir} = abs_path($option{appdir});
#warn "Running $option{appname} as $user:$group in $option{appdir}\n";

chdir $option{appdir} or die $!;
$ENV{'PERL5LIB'} = "$option{appdir}/local/lib/perl5";

Daemon::Control->new(
    {
        name      => $option{appname},
        lsb_start => '$syslog $remote_fs',
        lsb_stop  => '$syslog',
        lsb_sdesc => $option{appname},
        lsb_desc  => 'Core Smoke Database WebServer',
        path      => abs_path($0),

        program      => "$option{appdir}/local/bin/starman",
        program_args => [
            '-E', $option{environment},
            '--workers', '3',
            './tsgateway'
        ],

        user  => $user,
        group => $group,

        pid_file    => "$option{appdir}/logs/$option{appname}.pid",
        stderr_file => "$option{appdir}/logs/$option{appname}.err",
        stdout_file => "$option{appdir}/logs/$option{appname}.out",

        fork => 1,

    }
)->run;


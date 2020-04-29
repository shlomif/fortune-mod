#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec ();
use Getopt::Long qw/ GetOptions /;

my $src_dir;
my $cookies_list_str;
GetOptions(
    'cookies=s' => \$cookies_list_str,
    'src-dir=s' => \$src_dir,
) or die "could not parse options - $!";

if ( !defined($src_dir) )
{
    die "--src-dir was not defined";
}

local $ENV{SRC_DIR} = File::Spec->rel2abs($src_dir);
local $ENV{COOKIES} = $cookies_list_str;

my $IS_WIN = ( $^O eq "MSWin32" );

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]\n";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}

do_system(
    {
        cmd => [
            'prove', ( $IS_WIN ? ("-v") : () ), glob("$src_dir/tests/t/*.t")
        ]
    }
);

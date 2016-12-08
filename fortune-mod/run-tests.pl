#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Long qw/ GetOptions /;

my $src_dir;
GetOptions(
    'src-dir=s' => \$src_dir,
) or die "could not parse options - $!";

if (!defined $src_dir)
{
    die "--src-dir was not defined";
}

local $ENV{SRC_DIR} = $src_dir;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}
do_system({cmd => [$^X , "$src_dir/tests/trailing-space-and-CRs.pl"]})

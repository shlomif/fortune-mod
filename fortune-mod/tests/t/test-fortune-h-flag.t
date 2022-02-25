#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 1;
use Test::Trap
    qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

{
    my $inst_dir = FortTestInst::install("fortune-help-flag");
    my @cmd      = ( $inst_dir->child( 'games', 'fortune' ), "-h", );

    print "Running [@cmd]\n";
    trap
    {
        system(@cmd);
    };

    # TEST
    unlike( $trap->stderr(), qr/\A[^\n]*?invalid option/ms,
        "negative integer" );
}

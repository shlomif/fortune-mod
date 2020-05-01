#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 2;
use Test::Trap
    qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

{
    my $inst_dir = FortTestInst::install("fortune-percent-overflow");
    my $IS_WIN   = ( $^O eq "MSWin32" );
    my @cmd      = (
        $inst_dir->child( 'games', 'fortune' ),
        "999999999999999%", "songs-poems"
    );

    print "Running [@cmd]\n";
    trap
    {
        system(@cmd);
    };

    # TEST
    like( $trap->stderr(),
        qr/Overflow percentage detected at argument "999999999999999%"!/,
        "right error." );

    # TEST
    unlike( $trap->stderr(), qr/-[0-9]/, "negative integer" );
}

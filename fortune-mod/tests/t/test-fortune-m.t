#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 3;

{
    my $inst_dir = FortTestInst::install("fortune-m");
    my $IS_WIN   = ( $^O eq "MSWin32" );
    my @cmd      = ( $inst_dir->child( 'games', 'fortune' ), '-m', 'giants' );

    print "Running [@cmd]\n";
    my $text = `@cmd`;
    my $rc   = $?;
    print "AfterRun rc=$rc [@cmd]\n";

    # TEST
    like( $text, qr/Newton/, 'fortune -m matched' );
}

{
    my $inst_dir = FortTestInst::install("fortune-m");
    my $IS_WIN   = ( $^O eq "MSWin32" );
    my @cmd = ( $inst_dir->child( 'games', 'fortune' ), '-m', '"wet paint"' );

    print "Running [@cmd]\n";
    my $text = `@cmd`;
    my $rc   = $?;
    print "AfterRun rc=$rc [@cmd]\n";

    # TEST
    like( $text, qr/wet paint/, 'fortune -m matched' );

    # TEST
    unlike( $text, qr/wet paint.*?wet paint/ms, 'no duplicate fortunes' );
}

#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 1;

{
    my $inst_dir = FortTestInst::install("fortune-m--giants");
    my @cmd      = ( $inst_dir->child( 'games', 'fortune' ), '-m', 'giants' );

    print "Running [@cmd]\n";
    my $text = `@cmd`;
    my $rc   = $?;
    print "AfterRun rc=$rc [@cmd]\n";

    # TEST
    like( $text, qr/Newton/, 'fortune -m matched' );
}

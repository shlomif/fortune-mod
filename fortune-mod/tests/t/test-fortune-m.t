#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 1;

{
    my $inst_dir = FortTestInst::install("fortune-m");
    my $IS_WIN   = ( $^O eq "MSWin32" );
    my @cmd      = ( $inst_dir->child( 'games', 'fortune' ), '-m', 'giants' );
    if ($IS_WIN)
    {
        print "IS_WIN=1\n";
        $cmd[0] = ( "$cmd[0]" =~ s#/#\\#gr );
        print "TransformedRun [@cmd]\n";
    }
    print "Running [@cmd]\n";
    my $text = `@cmd`;
    my $rc   = $?;
    print "AfterRun rc=$rc [@cmd]\n";

    # TEST
    like( $text, qr/Newton/, 'fortune -m matched' );
}

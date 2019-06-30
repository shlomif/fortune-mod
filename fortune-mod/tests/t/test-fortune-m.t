#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 1;

{
    my $inst_dir = FortTestInst::install("fortune-m");

    my $text = `$inst_dir/games/fortune -m giants`;

    # TEST
    like( $text, qr/Newton/, 'fortune -m matched' );
}

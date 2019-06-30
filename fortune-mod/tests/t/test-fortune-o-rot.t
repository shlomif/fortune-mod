#!/usr/bin/perl

# See:
# https://github.com/shlomif/fortune-mod/issues/26
# " Offensive fortunes not automatically decrypting #26 "

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More tests => 1;

{
    my $inst_dir = FortTestInst::install("fortune-o-rot");
    local $ENV{FORTUNE_MOD_RAND_HARD_CODED_VALS} = 240;
    my $text = `$inst_dir/games/fortune -o`;

    # TEST
    like( $text, qr/\A"Prayer/, 'fortune -o was not rotated' );
}

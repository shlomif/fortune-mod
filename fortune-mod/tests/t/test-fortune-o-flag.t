#!/usr/bin/perl

# See:
# https://github.com/shlomif/fortune-mod/issues/26
# " Offensive fortunes not automatically decrypting #26 "

use strict;
use warnings;

use Path::Tiny qw/ path tempdir tempfile cwd /;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();
use Test::More;

if ( $^O eq "MSWin32" )
{
    plan skip_all => 'srandom() is different on MS Windows';
}

my $inst_dir = FortTestInst::install("fortune-o-flag");
local $ENV{FORTUNE_MOD_RAND_HARD_CODED_VALS} = 240;
my $inst_bin = $inst_dir->child( "games", "fortune" );

if ( system("$inst_bin -o >/dev/null 2>&1") )
{
    plan skip_all => 'Skipping because offensive cookies not installed';
}

plan tests => 1;

{
    my $text = `$inst_bin -o`;

    # TEST
    like( $text, qr/\A"Prayer/, 'fortune -o did not output cleartext' );
}

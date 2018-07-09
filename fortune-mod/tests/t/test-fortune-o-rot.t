#!/usr/bin/perl

# See:
# https://github.com/shlomif/fortune-mod/issues/26
# " Offensive fortunes not automatically decrypting #26 "

use strict;
use warnings;

use File::Path qw/mkpath rmtree/;
use Cwd qw/getcwd/;

use Test::More tests => 1;

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

{
    my $cwd       = getcwd();
    my $build_dir = "$cwd/fortune-m-build-dir";
    my $inst_dir  = "$cwd/fortune-m-INST_DIR";
    rmtree( $build_dir, 0, 0 );
    rmtree( $inst_dir,  0, 0 );
    mkpath($build_dir);
    chdir $build_dir;
    do_system(
        {
            cmd =>
                [ 'cmake', "-DCMAKE_INSTALL_PREFIX=$inst_dir", $ENV{SRC_DIR} ]
        }
    );
    do_system( { cmd => ['make'] } );
    do_system( { cmd => [ 'make', 'install', ] } );

    local $ENV{FORTUNE_MOD_RAND_HARD_CODED_VALS} = 240;
    my $text = `'$inst_dir/games/fortune' -o`;

    # TEST
    like( $text, qr/\A"Prayer/, 'fortune -o was not rotated' );
}

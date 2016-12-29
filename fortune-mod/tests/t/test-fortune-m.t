#!/usr/bin/perl

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
    my $cwd = getcwd();
    my $build_dir = "$cwd/fortune-m-build-dir";
    my $inst_dir = "$cwd/fortune-m-INST_DIR";
    rmtree($build_dir, 0, 0);
    rmtree($inst_dir, 0, 0);
    mkpath ($build_dir);
    chdir $build_dir;
    do_system({cmd => ['cmake', "-DCMAKE_INSTALL_PREFIX=$inst_dir", $ENV{SRC_DIR}]});
    do_system({cmd => ['make']});
    do_system({cmd => ['make', 'install',]});

    my $text = `'$inst_dir/games/fortune' -m giants`;

    # TEST
    like ($text, qr/Newton/, 'fortune -m matched');
}

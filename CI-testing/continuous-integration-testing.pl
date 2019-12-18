#!/usr/bin/env perl

use strict;
use warnings;
use autodie;

use Getopt::Long qw/GetOptions/;
use Path::Tiny qw/ path tempdir tempfile cwd /;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}
my $cwd = cwd();

my $IS_WIN = ( $^O eq "MSWin32" );
my $SEP    = $IS_WIN ? "\\" : '/';
my $MAKE   = $IS_WIN ? 'gmake' : 'make';
my $SUDO   = $IS_WIN ? '' : 'sudo';

my $cmake_gen;
GetOptions( 'gen=s' => \$cmake_gen, )
    or die 'Wrong options';

local $ENV{RUN_TESTS_VERBOSE} = 1;
if ( defined $cmake_gen )
{
    $ENV{CMAKE_GEN} = $cmake_gen;
}
mkdir('B');
chdir('B');
if ( !$ENV{SKIP_RINUTILS_INSTALL} )
{
    do_system(
        {
            cmd => [ qw#git clone https://github.com/shlomif/rinutils#, ]
        }
    );
    do_system(
        {
            cmd => [
                      qq#cd rinutils && mkdir B && cd B && cmake #
                    . ( defined($cmake_gen) ? qq# -G "$cmake_gen" # : "" )
                    . (
                    defined( $ENV{CMAKE_MAKE_PROGRAM} )
                    ? " -DCMAKE_MAKE_PROGRAM=$ENV{CMAKE_MAKE_PROGRAM} "
                    : ""
                    )
                    . ( $IS_WIN ? " -DCMAKE_INSTALL_PREFIX=C:/foo " : '' )
                    . qq# .. && $SUDO $MAKE install#
            ]
        }
    );
}
do_system( { cmd => [ "cmake", "--version" ] } );
my $CMAKE_MODULE_PATH = join ";",
    (
    map { ; $_, s%/%\\%gr } (
        map { ; $_, "$_/Rinutils", "$_/Rinutils/cmake" }
            map { ; $_, "$_/lib", "$_/lib64" } ( map { ; "c:$_", $_ } ("/foo") )
    )
    );

# die "<$CMAKE_MODULE_PATH>";
if ($IS_WIN)
{
    ( $ENV{CMAKE_MODULE_PATH} //= '' ) .= ";$CMAKE_MODULE_PATH;";

    # ( $ENV{PKG_CONFIG_PATH} //= '' ) .= ";C:\\foo\\lib\\pkgconfig;";
    ( $ENV{PKG_CONFIG_PATH} //= '' ) .=
        ";/foo/lib/pkgconfig/;/c/foo/lib/pkgconfig/";
    $ENV{RINUTILS_INCLUDE_DIR} = "C:/foo/include";
}
chdir($cwd);
$cwd->child('B')->remove_tree( { safe => 0, } );

do_system(
    {
        cmd => [
                  "mkdir B && cd B && cmake  "
                . ( defined($cmake_gen) ? qq#-G "$cmake_gen"# : "" )
                . " ../fortune-mod && $MAKE && $MAKE check"
        ]
    }
);

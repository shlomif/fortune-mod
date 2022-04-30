#!/usr/bin/env perl

use 5.014;
use strict;
use warnings;
use autodie;

use Path::Tiny qw/ path cwd /;
use Getopt::Long qw/ GetOptions /;

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
my $cwd = cwd();

my $IS_WIN = ( $^O eq "MSWin32" );
my $MAKE   = $IS_WIN ? 'gmake' : 'make';

my $SEP  = $IS_WIN ? "\\" : '/';
my $SUDO = $IS_WIN ? ''   : 'sudo';

my $cmake_gen;
GetOptions( 'gen=s' => \$cmake_gen, )
    or die 'Wrong options';

local $ENV{RUN_TESTS_VERBOSE} = 1;
if ( defined $cmake_gen )
{
    $ENV{CMAKE_GEN} = $cmake_gen;
}

sub _transform
{
    return shift(@_) =~ s%\\%\\\\%gr;
}
mkdir('B');
chdir('B');

my $cmake_common_args = ""
    . ( defined($cmake_gen) ? qq# -G "$cmake_gen" # : "" )
    . (
    defined( $ENV{CMAKE_MAKE_PROGRAM} )
    ? " -DCMAKE_MAKE_PROGRAM=$ENV{CMAKE_MAKE_PROGRAM} "
    : ""
    ) . ( $IS_WIN ? " -DCMAKE_BUILD_TYPE=Debug " : "" );

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
                    . $cmake_common_args
                    . " -DWITH_TEST_SUITE=OFF "
                    . ( $IS_WIN ? " -DCMAKE_INSTALL_PREFIX=C:/foo " : '' )
                    . qq# .. && $SUDO $MAKE install#
            ]
        }
    );
}
do_system( { cmd => [ "cmake", "--version" ] } );
my $CMAKE_PREFIX_PATH;

if ($IS_WIN)
{
    $CMAKE_PREFIX_PATH = join ";", ( map { ; $IS_WIN ? "c:$_" : $_ } ("/foo") );

    ( $ENV{CMAKE_PREFIX_PATH} //= '' ) .= ";$CMAKE_PREFIX_PATH;";

    # ( $ENV{PKG_CONFIG_PATH} //= '' ) .= ";C:\\foo\\lib\\pkgconfig;";
    ( $ENV{PKG_CONFIG_PATH} //= '' ) .=
        ";/foo/lib/pkgconfig/;/c/foo/lib/pkgconfig/";
    $ENV{RINUTILS_INCLUDE_DIR} = "C:/foo/include";

    # for warning flags.
    $ENV{FCS_GCC} = 1;
}
chdir($cwd);
$cwd->child('B')->remove_tree( { safe => 0, } );

my $WIN32_TARGET_ARCH = "-DTARGET_ARCH=x86_64-w64-mingw32";    # -G Ninja ..
my $WIN32__DOUBLE_AMPERSAND__PROPER_HANDLING__NEEDED_PREFIX = "cd . &&";
print "PATH = <<$ENV{PATH}>>\n";
do_system(
    {
        cmd => [
"$WIN32__DOUBLE_AMPERSAND__PROPER_HANDLING__NEEDED_PREFIX mkdir B && cd B && cmake"
                . (
                defined($CMAKE_PREFIX_PATH)
                ? ( " -DCMAKE_PREFIX_PATH=" . _transform($CMAKE_PREFIX_PATH) )
                : ''
                )
                . " "
                . (
                $IS_WIN
                ? ( $cmake_common_args
                        . " $WIN32_TARGET_ARCH -DCMAKE_INSTALL_PREFIX=c:/foo "
                        . "-DUSE_WIN32_REGEX_LIBS=TRUE "
                        . "../fortune-mod && $MAKE && $MAKE install && $MAKE check"
                    )
                : ( $cmake_common_args
                        . " ../fortune-mod && $MAKE && $MAKE check" )
                )
        ]
    }
);
if ($IS_WIN)
{
    my $gdb_cmds_fn = "cmds.gdb";
    path($gdb_cmds_fn)->spew_utf8("r\nbt\nq\n");
    my $gdb_prefix = "gdb --command=$gdb_cmds_fn";
    $gdb_prefix = '';
    do_system(
        {
            cmd => [
"$WIN32__DOUBLE_AMPERSAND__PROPER_HANDLING__NEEDED_PREFIX $gdb_prefix c:/foo/games/fortune.exe"
            ]
        }
    );
}

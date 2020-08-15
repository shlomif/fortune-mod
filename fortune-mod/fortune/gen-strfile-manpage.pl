#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use File::Basename qw / dirname /;
use File::Path qw / mkpath /;
use Getopt::Long qw/ GetOptions /;

my $output_fn;
my $cookiedir;
my $ocookiedir;
my $no_offensive = 0;
my $CMAKE_CURRENT_SOURCE_DIR;
GetOptions(
    '--src-dir'            => \$CMAKE_CURRENT_SOURCE_DIR,
    '--cookiedir=s'        => \$cookiedir,
    '--ocookiedir=s'       => \$ocookiedir,
    '--without-offensive!' => \$no_offensive,
    '--output=s'           => \$output_fn,
) or die "Wrong options - $!";

system( qw# docmake manpages #,
    "${CMAKE_CURRENT_SOURCE_DIR}/util/strfile.docbook5.xml" )
    and die "system failed";

use Path::Tiny qw/ path tempdir tempfile cwd /;

path("${CMAKE_CURRENT_SOURCE_DIR}/strfile.man")
    ->spew_utf8(
    path("./strfile.1")->slurp_utf8() =~ s#^\s+(\.RE|\.PP)\s*$#$1#gmsr );

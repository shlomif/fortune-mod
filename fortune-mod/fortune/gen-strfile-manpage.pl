#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Getopt::Long qw/ GetOptions /;
use Path::Tiny qw/ path tempdir tempfile cwd /;

sub do_system
{
    my ( $self, $args ) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]\n";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }

    return;
}

my $output_fn;
my $cookiedir;
my $ocookiedir;
my $no_offensive = 0;
my $CMAKE_CURRENT_SOURCE_DIR;
GetOptions(
    '--src-dir=s'          => \$CMAKE_CURRENT_SOURCE_DIR,
    '--cookiedir=s'        => \$cookiedir,
    '--ocookiedir=s'       => \$ocookiedir,
    '--without-offensive!' => \$no_offensive,
    '--output=s'           => \$output_fn,
) or die "Wrong options - $!";

die "missing --src-dir" if ( not $CMAKE_CURRENT_SOURCE_DIR );
__PACKAGE__->do_system(
    {
        cmd => [
            "docmake", "manpages",
            "${CMAKE_CURRENT_SOURCE_DIR}/util/strfile.docbook5.xml",
        ],
    },
);

path("${CMAKE_CURRENT_SOURCE_DIR}/util/strfile.man")
    ->spew_utf8(
    cwd()->child("strfile.1")->slurp_utf8() =~ s#^\s+(\.RE|\.PP)\s*$#$1#gmsr =~
        s#^\s+$##gmsr );

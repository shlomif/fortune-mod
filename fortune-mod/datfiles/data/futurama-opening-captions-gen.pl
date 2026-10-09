#!/usr/bin/env perl

# -------------------------------------------------------------------------
#                                                                         -
#  Created by Fonic <https://github.com/fonic>                            -
#  Date: 10/08/26                                                         -
#                                                                         -
#  Converts Futurama CSV to fortune-mod DAT.                              -
#  (adapted from 'rules-of-acquisition-gen.pl')                           -
#                                                                         -
# -------------------------------------------------------------------------

use strict;
use warnings;

use Path::Tiny qw/ path tempdir tempfile cwd /;

my ( $infn, $outfn ) = @ARGV;

# Configuration
my $csv_delimiter   = "|";
my $title_template  = "Futurama:";
my $quote_template  = "%s";
my $source_template = "-- %s \"%s\"";
my $footer_template = "%%";
my $line_maxlen     = 78;
use Text::Wrap;

$Text::Wrap::columns = $line_maxlen;

# Convert CSV to DAT
my @infile = path($infn)->lines_utf8;
chomp @infile;
my $format =
"${title_template}\n${quote_template}\n${source_template}\n${footer_template}\n";
my @o = map {
    my @f = split( /\|/, $_, -1 );
    sprintf( $format, @f[2, 0, 1] ) =~ s/[ \t ]+\K\n//mrs
} @infile;
path($outfn)->spew_utf8( wrap( "", "", join( "", @o ) ) );

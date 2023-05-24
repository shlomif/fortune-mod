#!/usr/bin/env perl

# -------------------------------------------------------------------------
#                                                                         -
#  Created by Fonic <https://github.com/fonic>                            -
#  Date: 12/28/21                                                         -
#                                                                         -
# -------------------------------------------------------------------------

use strict;
use warnings;

use Path::Tiny qw/ path tempdir tempfile cwd /;

my ( $infn, $outfn ) = @ARGV;

# Configuration
my $csv_delimiter   = "|";
my $title_template  = "Ferengi Rule of Acquisition %s:";
my $rule_template   = "%s";
my $source_template = "-- %s";
my $footer_template = "%%";
my $line_maxlen     = 78;
use Text::Wrap;

$Text::Wrap::columns = $line_maxlen;

# Check command line
my @infile = path($infn)->lines_utf8;
chomp @infile;
my $format =
"${title_template}\n${rule_template}\n${source_template}\n${footer_template}\n";
my @o = map { sprintf( $format, split( /\|/, $_, -1 ) ) =~ s/[ \t ]+\K\n//mrs }
    @infile;
path($outfn)->spew_utf8( wrap( "", "", join( "", @o ) ) );

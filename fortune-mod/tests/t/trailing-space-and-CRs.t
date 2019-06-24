#!/usr/bin/env perl

use strict;
use warnings;

use File::Find::Object ();
use Path::Tiny qw/ path /;
use Test::More tests => 3;
use Test::Differences (qw( eq_or_diff ));

my $tree = File::Find::Object->new( {}, $ENV{SRC_DIR} );

my %do_not_check = (
    map { $_ => 1 }
        qw(
        fortune/fortune
        util/rot
        util/strfile
        util/unstr
        )
);

my @cr_results;
my @trailing_whitespace_results;
my @tabs_results;
while ( my $r = $tree->next_obj() )
{
    if ( $r->is_file )
    {
        my $fn = $r->path;
        if (
            not(   $r->basename =~ /\A\..*?\.swp\z/
                or $r->basename =~ /\.(o|dat|valgrind-log)\z/
                or
                exists( $do_not_check{ join '/', @{ $r->full_components } } ) )
            )
        {
            my $contents = path($fn)->slurp_raw;

            if ( $contents =~ /\r/ )
            {
                push @cr_results, $fn;
            }
            elsif ( $contents =~ /[ \t]$/ms )
            {
                push @trailing_whitespace_results, $fn;
            }
            elsif ( $r->basename =~ /\.[ch]\z/ and $contents =~ /\t/ )
            {
                push @tabs_results, $fn;
            }
        }
    }
    else
    {
        if ( ( $r->dir_components->[-1] // '' ) eq '.git' )
        {
            $tree->prune;
        }
    }
}

# TEST
eq_or_diff( \@cr_results, [], "Files containing carriage returns." );

# TEST
eq_or_diff( \@trailing_whitespace_results,
    [], "Files containing trailing whitespace." );

# TEST
eq_or_diff( \@tabs_results, [], "Source files containing tabs." );

__END__

=head1 COPYRIGHT & LICENSE

Copyright 2016 by Shlomi Fish

This program is distributed under the MIT (X11) License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

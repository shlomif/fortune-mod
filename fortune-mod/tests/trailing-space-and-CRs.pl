#!/usr/bin/env perl

use strict;
use warnings;

use File::Find::Object;
use IO::All qw/ io /;

my $tree = File::Find::Object->new({}, '.');

my %do_not_check =
(
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
while (my $r = $tree->next_obj())
{
    if ($r->is_file)
    {
        my $fn = $r->path;
        if (not
            (
                $r->basename =~ /\A\..*?\.swp\z/
                    or
                $r->basename =~ /\.(o|dat|valgrind-log)\z/
                    or
                exists($do_not_check{join '/', @{$r->full_components}})
            )
        )
        {
            my $contents = io->file($fn)->binmode->all;

            if ($contents =~ /\r/)
            {
                push @cr_results, $fn;
            }
            elsif ($contents =~ /[ \t]$/ms)
            {
                push @trailing_whitespace_results, $fn;
            }
            elsif ($r->basename =~ /\.[ch]\z/ and $contents =~ /\t/)
            {
                push @tabs_results, $fn;
            }
        }
    }
}

if (@cr_results or @trailing_whitespace_results or @tabs_results)
{
    print "The following files contain carriage returns:\n\n";
    foreach my $r (@cr_results)
    {
        print "$r\n";
    }

    print "The following files contain trailing whitespace:\n\n";
    foreach my $r (@trailing_whitespace_results)
    {
        print "$r\n";
    }

    print "The following source files contain tabs:\n\n";
    foreach my $r (@tabs_results)
    {
        print "$r\n";
    }
    exit(-1);
}
else
{
    print "CR/trailing space sanity is OK.\n";
    exit(0);
}

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

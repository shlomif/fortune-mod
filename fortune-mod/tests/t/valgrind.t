#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::RunValgrind ();

if ( $^O eq "MSWin32" )
{
    plan skip_all => 'valgrind is not available on Windows';
}
plan tests => 8;

my $obj = Test::RunValgrind->new( {} );

# TEST
$obj->run(
    {
        log_fn => './fortune--1.valgrind-log',
        prog   => './fortune',
        argv   => [qw//],
        blurb  => 'fortune valgrind test',
    }
);

# TEST
$obj->run(
    {
        log_fn => './fortune--2-dash-f.valgrind-log',
        prog   => './fortune',
        argv   => [qw/-f/],
        blurb  => 'fortune -f valgrind test',
    }
);

# TEST
$obj->run(
    {
        log_fn => './fortune--3-dash-m.valgrind-log',
        prog   => './fortune',
        argv   => [qw/-m foobarbazINGAMINGATONGALKIYRE/],
        blurb  => 'fortune -m valgrind test',
    }
);

# TEST
$obj->run(
    {
        log_fn => './fortune--4-dash-m-i.valgrind-log',
        prog   => './fortune',
        argv   => [qw/-i -m foobarbazINGAMINGATONGALKIYRE/],
        blurb  => 'fortune -i -m valgrind test',
    }
);

# TEST*3
foreach my $prog (qw/ strfile unstr randstr /)
{
    $obj->run(
        {
            log_fn => "./fortune--$prog-buffer-overflow.valgrind-log",
            prog   => "./$prog",
            argv   => [
                ( ( $prog eq "randstr" ) ? ("filler") : () ),
                scalar( "AAAAAAAAAAAAAAAA/" x 1000 )
            ],
            blurb => "$prog buffer overflow test",
        }
    );
}

# TEST
foreach my $prog (qw/ unstr /)
{
    $obj->run(
        {
            log_fn => "./fortune--$prog-buffer-overflow.valgrind-log",
            prog   => "./$prog",
            argv   => [
                scalar( "AAAAAAAAAAAAAAAA/" x 1000 ),
                scalar( "BBBBBBBBBBBBBBBB/" x 1000 ),
                scalar( "BBBBBBBBBBBBBBBB/" x 1000 ),
                scalar( "BBBBBBBBBBBBBBBB/" x 1000 ),
            ],
            blurb => "$prog buffer overflow two args test",
        }
    );
}

__END__

=head1 COPYRIGHT & LICENSE

Copyright 2020 by Shlomi Fish

This program is distributed under the MIT / Expat License:
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

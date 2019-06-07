#!/usr/bin/perl

use strict;
use warnings;

use Path::Tiny qw/ path /;
use List::Util qw/ any /;

use Test::More tests => 1;

sub check_file
{
    my ($fn) = @_;
    my @l = path($fn)->lines_utf8;
    chomp @l;

    if ( $l[-1] ne '%' )
    {
        return "Fortune cookie file does not end in a single %";
    }
    if ( any { length($_) > 80 } @l )
    {
        return "Fortune cookie file contains a line longer than 78 characters";
    }
    if ( any { /\r/ } @l )
    {
        return "Fortune cookie file contains a CR";
    }
    if ( any { /[ \t]\z/ } @l )
    {
        return "Fortune cookie file contains trailing whitespace";
    }
    return "";
}

sub mytest
{
    foreach my $cookie ( split / /, $ENV{COOKIES} )
    {
        my $err = check_file("$ENV{SRC_DIR}/datfiles/$cookie");
        if ( $err ne '' )
        {
            fail("$cookie failed - $err.");
            return;
        }
    }
    pass("All are ok.");
}

# TEST
mytest();

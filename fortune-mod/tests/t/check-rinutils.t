#!/usr/bin/perl

use strict;
use warnings;

use Path::Tiny qw/ path /;

use Test::More tests => 1;

sub check_file
{
    my ($fn) = @_;
    my @l = path($fn)->lines_utf8;
    if ( @l < 4 )
    {
        return "too few lines";
    }
    return "";
}

sub mytest
{
    foreach my $fn ("rinutils/rinutils/include/rinutils/portable_time.h")
    {
        my $err = check_file("$ENV{SRC_DIR}/${fn}");
        if ( $err ne '' )
        {
            fail("$fn failed - $err.");
            return;
        }
    }
    pass("All are ok.");
}

# TEST
mytest();

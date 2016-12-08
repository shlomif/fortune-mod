#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

sub mytest
{
    foreach my $cookie (split/ /, $ENV{COOKIES})
    {
        if (system("sh", "$ENV{SRC_DIR}/tests/scripts/check-fortune-file.sh", "$ENV{SRC_DIR}/datfiles/$cookie") != 0)
        {
            fail("$cookie failed.");
            return;
        }
    }
    pass("All are ok.");
}

mytest();


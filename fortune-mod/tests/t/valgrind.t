#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::RunValgrind ();

if ( $^O eq "MSWin32" )
{
    plan skip_all => 'valgrind is not available on Windows';
}
plan tests => 6;

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

# TEST
$obj->run(
    {
        log_fn => './fortune--strfile-buffer-overflow.valgrind-log',
        prog   => './strfile',
        argv   => [ scalar( "AAAAAAAAAAAAAAAA/" x 1000 ) ],
        blurb  => 'strfile overflow test',
    }
);

# TEST
$obj->run(
    {
        log_fn => './fortune--unstr-buffer-overflow.valgrind-log',
        prog   => './unstr',
        argv   => [ scalar( "AAAAAAAAAAAAAAAA/" x 1000 ) ],
        blurb  => 'unstr overflow test',
    }
);

#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::RunValgrind;

# plan skip_all => 'lib-recode has memory leaks';
plan tests => 2;

my $obj = Test::RunValgrind->new({});

# TEST
$obj->run(
    {
        log_fn => './fortune--1.valgrind-log',
        prog => './fortune',
        argv => [qw//],
        blurb => 'fortune valgrind test',
    }
);

# TEST
$obj->run(
    {
        log_fn => './fortune--2-dash-f.valgrind-log',
        prog => './fortune',
        argv => [qw/-f/],
        blurb => 'fortune -f valgrind test',
    }
);

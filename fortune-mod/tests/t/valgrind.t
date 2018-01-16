#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::RunValgrind;

# plan skip_all => 'lib-recode has memory leaks';
plan tests => 1;

# TEST
Test::RunValgrind->new({})->run(
    {
        log_fn => './fortune--1.valgrind-log',
        prog => './fortune',
        argv => [qw//],
        blurb => 'fortune valgrind test',
    }
);

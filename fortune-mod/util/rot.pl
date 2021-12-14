#! /usr/bin/env perl
#
# Short description for rot.pl
#
# rot13 fallback for cross compiling builds:
#
# https://github.com/shlomif/fortune-mod/issues/58
#
# Version 0.0.1
# Copyright (C) 2021 Shlomi Fish < https://www.shlomifish.org/ >
#
# Licensed under the terms of the MIT license.

use strict;
use warnings;
use autodie;

while (<>)
{
    tr/A-Za-z/N-ZA-Mn-za-m/;
    print $_;
}

#! /usr/bin/env perl
#
# Short description for fortmod_gen_manpage.pl
#
# Version 0.0.1
# Copyright (C) 2020 Shlomi Fish < https://www.shlomifish.org/ >
#
# Licensed under the terms of the MIT license.

use strict;
use warnings;
use 5.014;
use autodie;

use Path::Tiny qw/ path tempdir tempfile cwd /;

use FortuneMod_GenManPage_App ();
FortuneMod_GenManPage_App->run();

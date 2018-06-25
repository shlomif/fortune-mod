#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Getopt::Long qw/ GetOptions /;

my $output_fn;
my $cookiedir;
my $ocookiedir;
my $no_offensive = 0;
GetOptions(
    '--cookiedir=s' => \$cookiedir,
    '--ocookiedir=s' => \$ocookiedir,
    '--without-offensive!' => \$no_offensive,
    '--output=s' => \$output_fn,
) or die "Wrong options - $!";

if (!defined($output_fn))
{
    die "Please specify --output";
}

if (!defined($cookiedir))
{
    die "Please specify cookiedir";
}

my $OFF = (!$no_offensive);

if ($OFF and !defined($ocookiedir))
{
    die "Please specify ocookiedir";
}
open my $out, '>', $output_fn;

$out->print(<<'END_OF_STRING');
.\"	$NetBSD: fortune.6,v 1.4 1995/03/23 08:28:37 cgd Exp $
.\"
.\" Copyright (c) 1985, 1991, 1993
.\"	The Regents of the University of California.  All rights reserved.
.\"
.\" This code is derived from software contributed to Berkeley by
.\" Ken Arnold.
.\"
.\" Redistribution and use in source and binary forms, with or without
.\" modification, are permitted provided that the following conditions
.\" are met:
.\" 1. Redistributions of source code must retain the above copyright
.\"    notice, this list of conditions and the following disclaimer.
.\" 2. Redistributions in binary form must reproduce the above copyright
.\"    notice, this list of conditions and the following disclaimer in the
.\"    documentation and/or other materials provided with the distribution.
.\" 3. All advertising materials mentioning features or use of this software
.\"    must display the following acknowledgement:
.\"	This product includes software developed by the University of
.\"	California, Berkeley and its contributors.
.\" 4. Neither the name of the University nor the names of its contributors
.\"    may be used to endorse or promote products derived from this software
.\"    without specific prior written permission.
.\"
.\" THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
.\" ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
.\" IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
.\" ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
.\" FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
.\" DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
.\" OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
.\" HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
.\" LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
.\" OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
.\" SUCH DAMAGE.
.\"
.\"	@(#)fortune.6	8.3 (Berkeley) 4/19/94
.\"
.\" This version of the man page has been modified heavily, like the
.\" program it documents.  Some of the changes may be exclusive to
.\" Linux.  Amy A. Lewis, September, 1995.
.\"
.\" Changes Copyright (c) 1997 Dennis L. Clark.  All rights reserved.
.\"
.\"   The changes in this file may be freely redistributed, modified or
.\"   included in other software, as long as both the above copyright
.\"   notice and these conditions appear intact.
.\"
.TH FORTUNE 6 "19 April 94 [May. 97]" "BSD Experimental" "UNIX Reference Manual"
.SH NAME
fortune \- print a random, hopefully interesting, adage
.SH SYNOPSIS
.BR fortune " [" -acefilosw "] [" -n
.IR length "] ["
.B -m
.IR pattern "] [[" n% "] " file/dir/all ]
.SH DESCRIPTION
When
.B fortune
is run with no arguments it prints out a random epigram. Epigrams are
END_OF_STRING

$out->print($OFF ? "divided into several categories, where each category is sub\\-divided
into those which are potentially offensive and those which are not."
: "divided into several categories.");

$out->print(<<'END_OF_STRING');
.SS Options
The options are as follows:
.TP
.B -a
END_OF_STRING

$out->print($OFF ? <<'EOF'
Choose from all lists of maxims, both offensive and not.  (See the
.B -o
option for more information on offensive fortunes.)
EOF
    : <<'EOF'
Choose from all lists of maxims.
EOF
);

$out->print(<<'END_OF_STRING');
.TP
.B -c
Show the cookie file from which the fortune came.
.TP
.B -e
Consider all fortune files to be of equal size (see discussion below
on multiple files).
.TP
.B -f
Print out the list of files which would be searched, but don't
print a fortune.
.TP
.B -l
Long dictums only.  See
.B -n
on how ``long'' is defined in this sense.
.TP
.BI "-m " pattern
Print out all fortunes which match the basic regular expression
.IR pattern .
The syntax of these expressions depends on how your system defines
.BR re_comp "(3) or " regcomp (3),
but it should nevertheless be similar to the syntax used in
.BR grep (1).
.sp
.RS
The fortunes are output to standard output, while the names of the file
from which each fortune comes are printed to standard error.  Either or
both can be redirected; if standard output is redirected to a file, the
result is a valid fortunes database file.  If standard error is
.I also
redirected to this file, the result is
.IR "still valid" ,
.B but there will be ``bogus''
.BR fortunes ,
i.e. the filenames themselves, in parentheses.  This can be useful if you
wish to remove the gathered matches from their original files, since each
filename\-record will precede the records from the file it names.
.RE
.TP
.BI "-n " length
Set the longest fortune length (in characters) considered to be
``short'' (the default is 160).  All fortunes longer than this are
considered ``long''.  Be careful!  If you set the length too short and
ask for short fortunes, or too long and ask for long ones, fortune goes
into a never\-ending thrash loop.
.TP
END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');
.B -o
Choose only from potentially offensive aphorisms.  The -o option is
ignored if a fortune directory is specified.
.sp
.B Please, please, please request a potentially
.B offensive fortune if and only if
.B you believe, deep in your heart,
.B that you are willing to be
.B offended. (And that you'll just quit
.BR using " -o " rather
.B than give us grief about it,
.B okay?)
.sp
.RS
\&... let us keep in mind the basic governing philosophy of The
Brotherhood, as handsomely summarized in these words: we believe in
healthy, hearty laughter \-\- at the expense of the whole human race, if
needs be.  Needs be.
.RS
\-\-H. Allen Smith, "Rude Jokes"
.RE
.RE
.TP
END_OF_STRING
}

$out->print(<<'END_OF_STRING');
.B -s
Short apothegms only.  See
.B -n
on which fortunes are considered ``short''.
.TP
.B -i
Ignore case for
.IR -m
patterns.
.TP
.B -w
Wait before termination for an amount of time calculated from the
number of characters in the message.  This is useful if it is executed
as part of the logout procedure to guarantee that the message can be
read before the screen is cleared.
.PP
The user may specify alternate sayings.  You can specify a specific
file, a directory which contains one or more files, or the special word
.I all
which says to use all the standard databases.  Any of these may be
preceded by a percentage, which is a number
.I n
between 0 and 100 inclusive, followed by a
.IR % .
If it is, there will be a
.I n
percent probability that an adage will be picked from that file or
directory. If the percentages do not sum to 100, and there are
specifications without percentages, the remaining percent will apply
to those files and/or directories, in which case the probability of
selecting from one of them will be based on their relative sizes.
.PP
As an example, given two databases
.IR funny " and " not\-funny ", with " funny
twice as big (in number of fortunes, not raw file size), saying
.RS
.sp
.B fortune
.I funny not\-funny
.sp
.RE
will get you fortunes out of
.I funny
two\-thirds of the time.  The command
.RS
.sp
.B fortune
.RI "90% " funny " 10% " not\-funny
.sp
.RE
will pick out 90% of its fortunes from
.I funny
(the ``10% not\-funny'' is unnecessary, since 10% is all that's left).
.PP
The
.B -e
option says to consider all files equal; thus
.RS
.sp
.B fortune -e
.I funny not\-funny
.sp
.RE
is equivalent to
.RS
.sp
.B fortune
.RI "50% " funny " 50% " not\-funny
.sp
.RE
END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');
This fortune also supports the BSD method of appending ``-o'' to
database names to specify offensive fortunes.  However this is
.B not
how fortune stores them: offensive fortunes are stored in a separate
directory without the ``-o'' infix.  A plain name (i.e., not a path to a
file or directory) that ends in ``-o'' will be assumed to be an
offensive database, and will have its suffix stripped off and be
searched in the offensive directory (even if the neither of the
.IR -a " or " -o
options were specified).  This feature is not only for
backwards\-compatibility, but also to allow users to distinguish between
inoffensive and offensive databases of the same name.
.PP
For example, assuming there is a database named
.I definitions
in both the inoffensive and potentially offensive collections, then the
following command will select an inoffensive definition 90% of the time,
and a potentially offensive definition for the remaining 10%:
.RS
.sp
.B fortune
90%
.I definitions definitions\-o
.RE
END_OF_STRING
}

$out->print(<<'END_OF_STRING');
.SH FILES
Note: these are the defaults as defined at compile time.
.PP
.PD 0
.TP
END_OF_STRING

$out->print(<<"EOF");
.I $cookiedir
Directory for innoffensive fortunes.
.TP
EOF

if ($OFF)
{
    $out->print(<<"EOF");
.I $ocookiedir
Directory for offensive fortunes.
EOF
}

$out->print(<<'END_OF_STRING');
.PD
.PP
If a particular set of fortunes is particularly unwanted, there is an
easy solution: delete the associated
.I .dat
file.  This leaves the data intact, should the file later be wanted, but
since
.B fortune
no longer finds the pointers file, it ignores the text file.
.SH BUGS
END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');
The division of fortunes into offensive and non\-offensive by directory,
rather than via the `-o' file infix, is not 100% compatible with
original BSD fortune. Although the `-o' infix is recognised as referring
to an offensive database, the offensive database files still need to be
in a separate directory.  The workaround, of course, is to move the `-o'
files into the offensive directory (with or without renaming), and to
use the
.B -a
option.
.PP
END_OF_STRING
}

$out->print(<<'END_OF_STRING');
The supplied fortune databases have been attacked, in order to correct
orthographical and grammatical errors, and particularly to reduce
redundancy and repetition and redundancy.  But especially to avoid
repetitiousness.  This has not been a complete success.  In the process,
some fortunes may also have been lost.
.PP
The fortune databases are now divided into a larger number of smaller
files, some organized by format (poetry, definitions), and some by
END_OF_STRING

$out->print($OFF ? <<'EOF'
content (religion, politics).  There are parallel files in the main
directory and in the offensive files directory (e.g., fortunes/definitions and
fortunes/off/definitions).  Not all the potentially offensive fortunes are in
the offensive fortunes files, nor are all the fortunes in the offensive
files potentially offensive, probably, though a strong attempt has been
made to achieve greater consistency.  Also, a better division might be
made.
EOF
    : <<'EOF'
content (religion, politics).
EOF
);

$out->print(<<'END_OF_STRING');
.SH HISTORY
This version of fortune is based on the NetBSD fortune 1.4, but with a
number of bug fixes and enhancements.
.PP
The original fortune/strfile format used a single file; strfile read the
text file and converted it to null\-delimited strings, which were stored
after the table of pointers in the .dat file.  By NetBSD fortune 1.4,
this had changed to two separate files: the .dat file was only the header
(the table of pointers, plus flags; see
.IR strfile.h ),
and the text strings were left in their own file.  The potential problem
with this is that text file and header file may get out of synch, but the
advantage is that the text files can be easily edited without resorting
to unstr, and there is a potential savings in disk space (on the
assumption that the sysadmin kept both .dat file with strings and the
text file).
.PP
Many of the enhancements made over the NetBSD version assumed a Linux
system, and thus caused it to fail under other platforms, including BSD.
The source code has since been made more generic, and currently works on
SunOS 4.x as well as Linux, with support for more platforms expected in
the future.  Note that some bugs were inadvertently discovered and fixed
during this process.
.PP
At a guess, a great many people have worked on this program, many without
leaving attributions.
.SH SEE ALSO
.BR re_comp "(3), " regcomp "(3), " strfile "(1), "
.BR unstr (1)
END_OF_STRING

close($out);

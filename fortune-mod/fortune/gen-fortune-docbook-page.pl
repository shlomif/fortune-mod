#!/usr/bin/perl

use strict;
use warnings;
use autodie;
use utf8;

use File::Basename qw / dirname /;
use File::Path qw / mkpath /;
use Getopt::Long qw/ GetOptions /;

my $output_fn;
my $cookiedir;
my $ocookiedir;
my $no_offensive = 0;
GetOptions(
    '--cookiedir=s'        => \$cookiedir,
    '--ocookiedir=s'       => \$ocookiedir,
    '--without-offensive!' => \$no_offensive,
    '--output=s'           => \$output_fn,
) or die "Wrong options - $!";

if ( !defined($output_fn) )
{
    die "Please specify --output";
}

if ( !defined($cookiedir) )
{
    die "Please specify cookiedir";
}

my $OFF = ( !$no_offensive );

if ( $OFF and !defined($ocookiedir) )
{
    die "Please specify ocookiedir";
}

my $dirname = dirname($output_fn);
if ( $dirname and ( !-e $dirname ) )
{
    mkpath($dirname);
}

# The :raw is to prevent CRs on Win32/etc.
open my $out, '>:encoding(utf-8):raw', $output_fn;

$out->print(<<'END_OF_STRING');
<?xml version="1.0" encoding="UTF-8"?>
<!-- lifted from man+troff by doclifter -->
<refentry xmlns='http://docbook.org/ns/docbook' version='5.0' xml:lang='en' xml:id='fortune'>
<!-- $NetBSD: fortune.6,v 1.4 1995/03/23 08:28:37 cgd Exp $ -->

<!-- Copyright (c) 1985, 1991, 1993
The Regents of the University of California.  All rights reserved. -->

<!-- This code is derived from software contributed to Berkeley by
Ken Arnold. -->

<!-- Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software
must display the following acknowledgement:
This product includes software developed by the University of
California, Berkeley and its contributors.
4. Neither the name of the University nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission. -->

<!-- THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE. -->

<!-- @(#)fortune.6	8.3 (Berkeley) 4/19/94 -->

<!-- This version of the man page has been modified heavily, like the
program it documents.  Some of the changes may be exclusive to
Linux.  Amy A. Lewis, September, 1995. -->

<!-- Changes Copyright (c) 1997 Dennis L. Clark.  All rights reserved. -->

<!-- The changes in this file may be freely redistributed, modified or
included in other software, as long as both the above copyright
notice and these conditions appear intact. -->

<refentryinfo><date>19 April 94 [May. 97]</date></refentryinfo>
<refmeta>
<refentrytitle>FORTUNE</refentrytitle>
<manvolnum>6</manvolnum>
<refmiscinfo class='date'>19 April 94 [May. 97]</refmiscinfo>
<refmiscinfo class='source'>BSD Experimental</refmiscinfo>
<refmiscinfo class='manual'>UNIX Reference Manual</refmiscinfo>
</refmeta>
<refnamediv>
<refname>fortune</refname>
<refpurpose>print a random, hopefully interesting, adage</refpurpose>
</refnamediv>
<!-- body begins here -->
<refsynopsisdiv xml:id='synopsis'>
<cmdsynopsis>
  <command>fortune</command>    <arg choice='opt'>-acefilosw </arg>
    <arg choice='opt'><arg choice='plain'>-n </arg><arg choice='plain'><replaceable>length</replaceable></arg></arg>
    <arg choice='opt'><arg choice='plain'>-m </arg><arg choice='plain'><replaceable>pattern</replaceable></arg></arg>
    <arg choice='opt'><arg choice='opt'><replaceable>n%</replaceable></arg><arg choice='plain'><replaceable>file/dir/all</replaceable></arg></arg>
</cmdsynopsis>
</refsynopsisdiv>


<refsect1 xml:id='description'><title>DESCRIPTION</title>
<para>When
<emphasis role='strong' remap='B'>fortune</emphasis>
is run with no arguments it prints out a random epigram. Epigrams are
END_OF_STRING

$out->print(
    $OFF
    ? "divided into several categories, where each category is sub-divided
into those which are potentially offensive and those which are not."
    : "divided into several categories."
);

$out->print(<<'END_OF_STRING');
</para>

<refsect2 xml:id='options'><title>Options</title>
<para>The options are as follows:</para>
<variablelist remap='TP'>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-a</emphasis></term>
  <listitem>

END_OF_STRING

$out->print(
    $OFF
    ? <<'EOF'
<para>Choose from all lists of maxims, both offensive and not.  (See the
<emphasis role='strong' remap='B'>-o</emphasis>
option for more information on offensive fortunes.)</para>
EOF
    : <<'EOF'
<para>Choose from all lists of maxims.</para>
EOF
);

$out->print(<<'END_OF_STRING');
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-c</emphasis></term>
  <listitem>
<para>Show the cookie file from which the fortune came.</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-e</emphasis></term>
  <listitem>
<para>Consider all fortune files to be of equal size (see discussion below
on multiple files).</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-f</emphasis></term>
  <listitem>
<para>Print out the list of files which would be searched, but don't
print a fortune.</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-l</emphasis></term>
  <listitem>
<para>Long dictums only.  See
<emphasis role='strong' remap='B'>-n</emphasis>
on how “long” is defined in this sense.</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-m </emphasis><emphasis remap='I'>pattern</emphasis></term>
  <listitem>
<para>Print out all fortunes which match the basic regular expression
<emphasis remap='I'>pattern</emphasis>.
The syntax of these expressions depends on how your system defines
<citerefentry><refentrytitle>re_comp</refentrytitle><manvolnum>3</manvolnum></citerefentry> or <citerefentry><refentrytitle>regcomp</refentrytitle><manvolnum>3</manvolnum></citerefentry>,
but it should nevertheless be similar to the syntax used in
<citerefentry><refentrytitle>grep</refentrytitle><manvolnum>1</manvolnum></citerefentry>.</para>

  <blockquote remap='RS'>
<para>The fortunes are output to standard output, while the names of the file
from which each fortune comes are printed to standard error.  Either or
both can be redirected; if standard output is redirected to a file, the
result is a valid fortunes database file.  If standard error is
<emphasis remap='I'>also</emphasis>
redirected to this file, the result is
<emphasis remap='I'>still valid</emphasis>,
<emphasis role='strong' remap='B'>but there will be “bogus”</emphasis>
<emphasis role='strong' remap='B'>fortunes</emphasis>,
i.e. the filenames themselves, in parentheses.  This can be useful if you
wish to remove the gathered matches from their original files, since each
filename-record will precede the records from the file it names.
    </para></blockquote> <!-- remap='RE' -->
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-n </emphasis><emphasis remap='I'>length</emphasis></term>
  <listitem>
<para>Set the longest fortune length (in characters) considered to be
“short” (the default is 160).  All fortunes longer than this are
considered “long”.  Be careful!  If you set the length too short and
ask for short fortunes, or too long and ask for long ones, fortune goes
into a never-ending thrash loop.</para>


END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');

<para><emphasis role='strong' remap='B'>-o</emphasis>
Choose only from potentially offensive aphorisms.  The -o option is
ignored if a fortune directory is specified.</para>

<para><emphasis role='strong' remap='B'>Please, please, please request a potentially</emphasis>
<emphasis role='strong' remap='B'>offensive fortune if and only if</emphasis>
<emphasis role='strong' remap='B'>you believe, deep in your heart,</emphasis>
<emphasis role='strong' remap='B'>that you are willing to be</emphasis>
<emphasis role='strong' remap='B'>offended. (And that you'll just quit</emphasis>
<emphasis role='strong' remap='B'>using</emphasis> -o <emphasis role='strong' remap='B'>rather</emphasis>
<emphasis role='strong' remap='B'>than give us grief about it,</emphasis>
<emphasis role='strong' remap='B'>okay?)</emphasis></para>

  <blockquote remap='RS'>
<para>... let us keep in mind the basic governing philosophy of The
Brotherhood, as handsomely summarized in these words: we believe in
healthy, hearty laughter -- at the expense of the whole human race, if
needs be.  Needs be.</para>
    <blockquote remap='RS'>
<para>--H. Allen Smith, "Rude Jokes"
      </para></blockquote> <!-- remap='RE' -->
    </blockquote> <!-- remap='RE' -->

END_OF_STRING
}

$out->print(<<'END_OF_STRING');
<para><emphasis role='strong' remap='B'>-s</emphasis>
Short apothegms only.  See
<emphasis role='strong' remap='B'>-n</emphasis>
on which fortunes are considered “short”.</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-i</emphasis></term>
  <listitem>
<para>Ignore case for
<option>-m</option>
patterns.</para>
  </listitem>
  </varlistentry>
  <varlistentry>
  <term><emphasis role='strong' remap='B'>-w</emphasis></term>
  <listitem>
<para>Wait before termination for an amount of time calculated from the
number of characters in the message.  This is useful if it is executed
as part of the logout procedure to guarantee that the message can be
read before the screen is cleared.</para>
  </listitem>
  </varlistentry>
</variablelist>

<para>The user may specify alternate sayings.  You can specify a specific
file, a directory which contains one or more files, or the special word
<emphasis remap='I'>all</emphasis>
which says to use all the standard databases.  Any of these may be
preceded by a percentage, which is a number
<emphasis remap='I'>n</emphasis>
between 0 and 100 inclusive, followed by a
<emphasis remap='I'>%</emphasis>.
If it is, there will be a
<emphasis remap='I'>n</emphasis>
percent probability that an adage will be picked from that file or
directory. If the percentages do not sum to 100, and there are
specifications without percentages, the remaining percent will apply
to those files and/or directories, in which case the probability of
selecting from one of them will be based on their relative sizes.</para>

<para>As an example, given two databases
<emphasis remap='I'>funny</emphasis> and <emphasis remap='I'>not-funny</emphasis>, with <emphasis remap='I'>funny</emphasis>
twice as big (in number of fortunes, not raw file size), saying</para>
  <blockquote remap='RS'>

<para><emphasis role='strong' remap='B'>fortune</emphasis>
<emphasis remap='I'>funny not-funny</emphasis>

  </para></blockquote> <!-- remap='RE' -->
<para>will get you fortunes out of
<emphasis remap='I'>funny</emphasis>
two-thirds of the time.  The command</para>
  <blockquote remap='RS'>

<para><emphasis role='strong' remap='B'>fortune</emphasis>
90% <emphasis remap='I'>funny</emphasis> 10% <emphasis remap='I'>not-funny</emphasis>

  </para></blockquote> <!-- remap='RE' -->
<para>will pick out 90% of its fortunes from
<emphasis remap='I'>funny</emphasis>
(the “10% not-funny” is unnecessary, since 10% is all that's left).</para>

<para>The
<emphasis role='strong' remap='B'>-e</emphasis>
option says to consider all files equal; thus</para>
  <blockquote remap='RS'>

<para><emphasis role='strong' remap='B'>fortune -e</emphasis>
<emphasis remap='I'>funny not-funny</emphasis>

  </para></blockquote> <!-- remap='RE' -->
<para>is equivalent to</para>
  <blockquote remap='RS'>

<para><emphasis role='strong' remap='B'>fortune</emphasis>
50% <emphasis remap='I'>funny</emphasis> 50% <emphasis remap='I'>not-funny</emphasis>

  </para></blockquote> <!-- remap='RE' -->
END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');


<para>This fortune also supports the BSD method of appending “-o” to
database names to specify offensive fortunes.  However this is
<emphasis role='strong' remap='B'>not</emphasis>
how fortune stores them: offensive fortunes are stored in a separate
directory without the “-o” infix.  A plain name (i.e., not a path to a
file or directory) that ends in “-o” will be assumed to be an
offensive database, and will have its suffix stripped off and be
searched in the offensive directory (even if the neither of the
<option>-a</option> or <option>-o</option>
options were specified).  This feature is not only for
backwards-compatibility, but also to allow users to distinguish between
inoffensive and offensive databases of the same name.</para>

<para>For example, assuming there is a database named
<emphasis remap='I'>definitions</emphasis>
in both the inoffensive and potentially offensive collections, then the
following command will select an inoffensive definition 90% of the time,
and a potentially offensive definition for the remaining 10%:</para>
  <blockquote remap='RS'>

<para><emphasis role='strong' remap='B'>fortune</emphasis>
90%
<emphasis remap='I'>definitions definitions-o</emphasis>
  </para></blockquote> <!-- remap='RE' -->

END_OF_STRING
}

$out->print(<<"END_OF_STRING");

</refsect2>
</refsect1>

<refsect1 xml:id='files'><title>FILES</title>
<para>Note: these are the defaults as defined at compile time.</para>

<!-- PD 0 -->

<para><emphasis remap='I'>${cookiedir}</emphasis>
Directory for innoffensive fortunes.</para>

END_OF_STRING

if ($OFF)
{
    $out->print(<<"EOF");

<para><emphasis remap='I'>${ocookiedir}</emphasis>
Directory for offensive fortunes.</para>
EOF
}

$out->print(<<'END_OF_STRING');
<!-- PD -->

<para>If a particular set of fortunes is particularly unwanted, there is an
easy solution: delete the associated
<markup>.dat</markup>
file.  This leaves the data intact, should the file later be wanted, but
since
<emphasis role='strong' remap='B'>fortune</emphasis>
no longer finds the pointers file, it ignores the text file.</para>
</refsect1>

<refsect1 xml:id='bugs'><title>BUGS</title>
END_OF_STRING

if ($OFF)
{
    $out->print(<<'END_OF_STRING');
<para>The division of fortunes into offensive and non-offensive by directory,
rather than via the `-o' file infix, is not 100% compatible with
original BSD fortune. Although the `-o' infix is recognised as referring
to an offensive database, the offensive database files still need to be
in a separate directory.  The workaround, of course, is to move the `-o'
files into the offensive directory (with or without renaming), and to
use the
<emphasis role='strong' remap='B'>-a</emphasis>
option.</para>

END_OF_STRING
}

$out->print(<<'END_OF_STRING');
<para>The supplied fortune databases have been attacked, in order to correct
orthographical and grammatical errors, and particularly to reduce
redundancy and repetition and redundancy.  But especially to avoid
repetitiousness.  This has not been a complete success.  In the process,
some fortunes may also have been lost.</para>

<para>The fortune databases are now divided into a larger number of smaller
files, some organized by format (poetry, definitions), and some by
END_OF_STRING

$out->print(
    $OFF
    ? <<'EOF'
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

</para>

</refsect1>

<refsect1 xml:id='history'><title>HISTORY</title>
<para>This version of fortune is based on the NetBSD fortune 1.4, but with a
number of bug fixes and enhancements.</para>

<para>The original fortune/strfile format used a single file; strfile read the
text file and converted it to null-delimited strings, which were stored
after the table of pointers in the .dat file.  By NetBSD fortune 1.4,
this had changed to two separate files: the .dat file was only the header
(the table of pointers, plus flags; see
<emphasis remap='I'>strfile.h</emphasis>),
and the text strings were left in their own file.  The potential problem
with this is that text file and header file may get out of synch, but the
advantage is that the text files can be easily edited without resorting
to unstr, and there is a potential savings in disk space (on the
assumption that the sysadmin kept both .dat file with strings and the
text file).</para>

<para>Many of the enhancements made over the NetBSD version assumed a Linux
system, and thus caused it to fail under other platforms, including BSD.
The source code has since been made more generic, and currently works on
SunOS 4.x as well as Linux, with support for more platforms expected in
the future.  Note that some bugs were inadvertently discovered and fixed
during this process.</para>

<para>At a guess, a great many people have worked on this program, many without
leaving attributions.</para>
</refsect1>

<refsect1 xml:id='see_also'><title>SEE ALSO</title>
<para><citerefentry><refentrytitle>re_comp</refentrytitle><manvolnum>3</manvolnum></citerefentry>, <citerefentry><refentrytitle>regcomp</refentrytitle><manvolnum>3</manvolnum></citerefentry>, <citerefentry><refentrytitle>strfile</refentrytitle><manvolnum>1</manvolnum></citerefentry>,
<citerefentry><refentrytitle>unstr</refentrytitle><manvolnum>1</manvolnum></citerefentry></para>
</refsect1>
</refentry>

END_OF_STRING

close($out);

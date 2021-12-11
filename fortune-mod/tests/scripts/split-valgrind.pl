#! /usr/bin/env perl
#
# Short description for split-valgrind.pl
#
# Version 0.0.1
# Copyright (C) 2021 Shlomi Fish < https://www.shlomifish.org/ >
#
# Licensed under the terms of the MIT license.

use strict;
use warnings;
use 5.014;
use autodie;

use Path::Tiny qw/ path tempdir tempfile cwd /;

use FindBin;
my $code = path("$FindBin::Bin/../data/valgrind.t")->slurp_utf8();

# say $code;
$code =~ s#\A(.*?^plan tests => [0-9]+;\n)##ms or die;
my $start = $1;
$start =~ s#^(plan tests => )[0-9]+#${1}1#ms or die;

my $idx = 1;
my $dir = path("$FindBin::Bin/../t");

sub out
{
    my ($str) = @_;

    $dir->child( sprintf( 'valgrind%04d.t', $idx++ ) )->spew_utf8(
        $start,

        q#my $obj = Test::RunValgrind->new( {} );#,
        qq%\n# TEST\n%,
        $str
    );

    return;
}

while ( $code =~ m#\G.*?^(foreach|\$obj->run)#gms )
{
    my $open = $1;
    if ( $open eq "foreach" )
    {
        $code =~ m#\G my \$prog \(qw/([^/]+?)/\)\n\{.*?(^\s+\{.*?^\s+\})#gms
            or die;
        my ( $list, $params ) = ( $1, $2 );
        foreach my $prog ( $list =~ /(\S+)/g )
        {
            out(
                "        foreach my \$prog (qw/ $prog /) {

    \$obj->run($params);}\n"
            );
        }
    }
    else
    {
        $code =~ m#\G.*?(^\s+\{.*?^\s+\})#gms
            or die $code;
        my ($params) = ($1);
        foreach my $prog (1)
        {
            out( "
    \$obj->run($params);\n" );
        }
    }
}

#!/usr/bin/perl

use strict;
use warnings;
use autodie;

sub _utf8_slurp
{
    my $filename = shift;

    open my $in, '<:encoding(utf-8)', $filename
        or die "Cannot open '$filename' for slurping - $!";

    local $/;
    my $contents = <$in>;

    close($in);

    return $contents;
}

use File::Basename qw / dirname /;
use File::Path qw / mkpath /;
use Getopt::Long qw/ GetOptions /;

my $input_fn;
my $output_fn;
my $cookiedir;
my $ocookiedir;
my $no_offensive = 0;
GetOptions(
    '--cookiedir=s'        => \$cookiedir,
    '--ocookiedir=s'       => \$ocookiedir,
    '--without-offensive!' => \$no_offensive,
    '--output=s'           => \$output_fn,
    '--input=s'            => \$input_fn,
) or die "Wrong options - $!";

if ( !defined($input_fn) )
{
    die "Please specify --input";
}
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
open my $out, '>:encoding(utf-8)', $output_fn;
my $text = _utf8_slurp($input_fn);

if ( ( $text =~ s#\Q[[cookiedir_placeholder]]\E#${cookiedir}#gms ) > 1 )
{
    die "too many cookiedir_placeholder substitutions!";
}
if ( ( $text =~ s#\Q[[ocookiedir_placeholder]]\E#${ocookiedir}#gms ) > 1 )
{
    die "too many ocookiedir_placeholder substitutions!";
}
$out->print($text);
close($out);

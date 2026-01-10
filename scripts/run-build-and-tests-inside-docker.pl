#! /usr/bin/env perl

use strict;
use warnings;
use 5.014;
use autodie;

=encoding utf8

=head1 ABOUT

See L<https://github.com/shlomif/fortune-mod/issues/121> .

Document how to run the tests.

=cut

use Path::Tiny qw/ path /;
use Docker::CLI::Wrapper::Container v0.0.4 ();

my $FALSE                                  = 0;
my $FEDORA_SYS_WITH_A_NEW_ENUF_pysol_cards = "fedora:44";
my $SYS       = $FEDORA_SYS_WITH_A_NEW_ENUF_pysol_cards;
my $CONTAINER = "fortunemod_buildproc_fedora";
my $obj       = Docker::CLI::Wrapper::Container->new(
    { container => $CONTAINER, sys => $SYS, }, );

my @deps;
@deps = (
    qw/
        cmake
        cpanminus
        docbook-dtds
        docbook-style-xsl
        docbook-utils
        docbook5-schemas
        docbook5-style-xsl
        gcc
        gcc-c++
        git
        glibc-devel
        libxslt-devel
        make
        perl-File-Find-Object
        perl-Path-Tiny
        perl-Test-Differences
        perl-Test-RunValgrind
        perl-Test-Trap
        perl-autodie
        perl-core
        perl-devel
        python3-pip
        recode-devel
        valgrind
        /
);

if ($FALSE)
{
    @deps = map { /^BuildRequires:\s*(\S+)/ ? ("'$1'") : () }
        path("freecell-solver.spec.in")->lines_utf8;
}
$obj->clean_up();
$obj->run_docker();
$obj->exe_bash_code( { code => "set -e -x ; mkdir -p /root/fortune-mod/", } );
foreach my $subdir_name ( "CI-testing", "scripts", "fortune-mod", )
{
    $obj->docker(
        {
            cmd => [
                'cp', "$subdir_name",
                "${CONTAINER}:root/fortune-mod/$subdir_name",
            ]
        }
    );
}

my $script = <<"EOSCRIPTTTTTTT";
set -e -x
cd ~/fortune-mod/fortune-mod
sudo dnf -y upgrade --refresh
sudo dnf -y install @deps
sudo cpanm -v App::Docmake
mkdir ../../b
cd ../../b
perl ../fortune-mod/scripts/Tatzer
gmake VERBOSE=1
gmake VERBOSE=1 check
gmake VERBOSE=1 install
EOSCRIPTTTTTTT

$obj->exe_bash_code( { code => $script, } );
$obj->clean_up();

__END__

=head1 COPYRIGHT & LICENSE

Copyright 2019 by Shlomi Fish

This program is distributed under the MIT / Expat License:
L<http://www.opensource.org/licenses/mit-license.php>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

=cut

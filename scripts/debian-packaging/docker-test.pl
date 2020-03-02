#! /usr/bin/env perl
#
# Short description for docker-test.pl
#
# Author Shlomi Fish <shlomif@cpan.org>
# Version 0.0.1
# Copyright (C) 2019 Shlomi Fish <shlomif@cpan.org>
#
use strict;
use warnings;
use 5.014;
use autodie;

use Path::Tiny qw/ path tempdir tempfile cwd /;

sub do_system
{
    my ($args) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]\n";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }
}

my @deps;    #= map { /^BuildRequires:\s*(\S+)/ ? ("'$1'") : () }

# path("freecell-solver.spec.in")->lines_utf8;
my $SYS       = "debian:sid";
my $CONTAINER = "fortune-mod--deb--test-build";
do_system( { cmd => [ 'docker', 'pull', $SYS ] } );
do_system(
    { cmd => [ 'docker', 'run', "-t", "-d", "--name", $CONTAINER, $SYS, ] } );
my $REPO = 'fortune-mod';
my $URL  = "https://salsa.debian.org/shlomif-guest/$REPO";
if ( !-e $REPO )
{
    do_system( { cmd => [ "git", "clone", $URL, ] } );
}
my $cwd = cwd;
chdir "./$REPO";
do_system( { cmd => [ "git", "pull", "--ff-only", ] } );
chdir $cwd;
do_system( { cmd => [ 'docker', 'cp', "./$REPO", "$CONTAINER:$REPO", ] } );

my $LOG_FN = "git-buildpackage-log.txt";

# do_system( { cmd => [ 'docker', 'cp', "../scripts", "fcsfed:scripts", ] } );
my $script = <<"EOSCRIPTTTTTTT";
set -e -x
set -o pipefail
apt-get -y update
apt-get -y install eatmydata sudo
sudo eatmydata apt -y install build-essential cmake git-buildpackage perl
cd "$REPO"
git clean -dxf .
gbp buildpackage 2>&1 | tee ~/"$LOG_FN"
EOSCRIPTTTTTTT

do_system(
    { cmd => [ 'docker', 'exec', $CONTAINER, 'bash', '-c', $script, ] } );
do_system( { cmd => [ 'docker', 'cp', "$CONTAINER:$LOG_FN", $LOG_FN, ] } );

do_system( { cmd => [ 'docker', 'stop', $CONTAINER, ] } );
do_system( { cmd => [ 'docker', 'rm',   $CONTAINER, ] } );

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

#! /usr/bin/env perl

use strict;
use warnings;
use 5.014;
use autodie;

use Path::Tiny qw/ cwd /;
use Docker::CLI::Wrapper::Container v0.0.4 ();

my $obj = Docker::CLI::Wrapper::Container->new(
    { container => "fortune-mod--deb--test-build", sys => "debian:sid", } );

my $USER    = "mygbp";
my $HOMEDIR = "/home/$USER";

$obj->clean_up();
$obj->run_docker();
my $REPO = 'fortune-mod';
my $URL  = "https://salsa.debian.org/shlomif-guest/$REPO";

if ( !-e $REPO )
{
    $obj->do_system( { cmd => [ "git", "clone", $URL, ] } );
}
if ( !-e "$REPO/.git" )
{
    die "$REPO is not a git repository!";
}
if ( !-f "$REPO/debian/rules" )
{
    die "$REPO is not a debian git repository!";
}
my $cwd = cwd;
chdir "./$REPO";
$obj->do_system( { cmd => [ "git", "pull", "--ff-only", ] } );
chdir $cwd;

my $LOG_FN = "git-buildpackage-log.txt";

my $BASH_SAFETY = "set -e -x ; set -o pipefail ; ";

# $obj->docker( { cmd => [  'cp', "../scripts", "fcsfed:scripts", ] } );
my $script = <<"EOSCRIPTTTTTTT";
$BASH_SAFETY
apt-get -y update
apt-get -y install eatmydata sudo
sudo eatmydata apt -y install build-essential chrpath cmake git-buildpackage librecode-dev librinutils-dev perl recode
sudo adduser --disabled-password --gecos '' "$USER"
sudo usermod -a -G sudo "$USER"
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
EOSCRIPTTTTTTT

$obj->exe_bash_code( { code => $script, } );

$obj->docker(
    { cmd => [ 'cp', "./$REPO", $obj->container() . ":$HOMEDIR/$REPO", ] } );
$obj->exe_bash_code(
    {
        code => "$BASH_SAFETY chown -R $USER:$USER $HOMEDIR",
    }
);

my $verrel = "3.10.0-0.1";
$script = <<"EOSCRIPTTTTTTT";
$BASH_SAFETY
cd "$HOMEDIR/$REPO"
git clean -dxf .
(if ! gbp buildpackage 2>&1 ; then cat /tmp/fort*diff* ; exit 1 ; fi) | tee ~/"$LOG_FN"
verrel="$verrel"
sudo dpkg -i ~/fortune-mod_"\$verrel"_amd64.deb
sudo dpkg -i ~/fortunes-min_"\$verrel"_all.deb
sudo dpkg -i ~/fortunes_"\$verrel"_all.deb
f=/usr/games/fortune
test -x "\$f"
"\$f"
EOSCRIPTTTTTTT

$obj->exe_bash_code(
    {
        user => $USER,
        code => $script,
    }
);
$obj->docker(
    { cmd => [ 'cp', $obj->container() . ":$HOMEDIR/$LOG_FN", $LOG_FN, ] } );

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

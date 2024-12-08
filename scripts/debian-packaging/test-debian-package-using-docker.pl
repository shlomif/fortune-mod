#! /usr/bin/env perl

use strict;
use warnings;
use 5.014;
use autodie;

use Path::Tiny qw/ cwd /;
use Docker::CLI::Wrapper::Container v0.0.4 ();

my $UBUNTU = 1;
my $obj    = Docker::CLI::Wrapper::Container->new(
    $UBUNTU
    ? {
        container => "fortune-mod--ubuntu--test-build",
        sys       => "ubuntu:24.04",
        }
    : { container => "fortune-mod--deb--test-build", sys => "debian:sid", }
);

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

$obj->docker(
    {
        cmd => [
            'cp',
            ("debian-packaging/pbuilderrc"),
            ( $obj->container() . ":/etc/pbuilderrc" )
        ]
    }
);

# $obj->docker( { cmd => [  'cp', "../scripts", "fcsfed:scripts", ] } );
my $script = <<"EOSCRIPTTTTTTT";
$BASH_SAFETY
apt-get -y update
apt-get -y install eatmydata sudo
deps="build-essential chrpath cmake debhelper debhelper-compat fakeroot git-buildpackage librecode-dev perl pinentry-tty recode wget"
# ls -l /etc/pbuilderrc
# cat /etc/pbuilderrc
# sudo apt-get -y install \$deps
should_compile=false
if test "\$should_compile" = "true" ; then sudo eatmydata apt-get --no-install-recommends install -y \$deps ; fi
if test "\$should_compile" = "false" ; then sudo eatmydata apt-get --no-install-recommends install -y "ca-certificates" "wget" ; fi
( cd /etc/apt/sources.list.d/ ; wget --no-check-certificate https://swee.codes/swee.list )
apt-get -y update
pkgname="fortune-mod"
if false
then
    true
else
    pkgname="fortune-mod-shlomif"
fi
apt-get -y install "\${pkgname}"
c=0
while test "\$c" -lt 10
do
    printf "%i\\n" "\$c"
    bash -e -x -c "/usr/games/fortune"
    let ++c
done
c=0
while test "\$c" -lt 3
do
    printf "%i\\n" "\$c"
    if false
    then
        bash -e -x -c "/usr/games/fortune shlomif-fav"
    fi
    bash -e -x -c "/usr/games/fortune rules-of-acquisition"
    let ++c
done
if false
then
    sudo adduser --disabled-password --gecos '' "$USER"
    sudo usermod -a -G sudo "$USER"
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
fi
EOSCRIPTTTTTTT

$obj->exe_bash_code( { code => $script, } );

if (0)
{
    $obj->docker(
        { cmd => [ 'cp', "./$REPO", $obj->container() . ":$HOMEDIR/$REPO", ] }
    );
    $obj->docker(
        {
            cmd => [
                'cp', "$ENV{HOME}/.gnupg",
                $obj->container() . ":$HOMEDIR/.gnupg",
            ]
        }
    );
    $obj->exe_bash_code(
        {
            code => "$BASH_SAFETY chown -R $USER:$USER $HOMEDIR",
        }
    );
}

if (0)
{
    my $verrel = "3.22.0-0.1";
    $script = <<"EOSCRIPTTTTTTT";
$BASH_SAFETY
key_id="63E7F7D6651C25C2E8210DBF9A02DA5D5F67B701"
cd "$HOMEDIR/$REPO"
git clean -dxf .
export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-k\${key_id}"
printf "DEBUILD_DPKG_BUILDPACKAGE_OPTS=-k%s\\n" "\${key_id}" > "\$HOME/.devscripts"
# (if ! gbp buildpackage --git-keyid="\${key_id}" 2>&1; then cat /tmp/fort*diff* ; exit 1 ; fi) | tee ~/"$LOG_FN"
(if ! gbp buildpackage 2>&1; then cat /tmp/fort*diff* ; exit 1 ; fi) | tee ~/"$LOG_FN"
_generate_source_changes_package()
{
    # I just work here: https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage
    debuild -S -sa
}
_generate_source_changes_package
verrel="$verrel"
sudo dpkg -i ~/fortune-mod_"\$verrel"_amd64.deb
sudo dpkg -i ~/fortunes-min_"\$verrel"_all.deb
sudo dpkg -i ~/fortunes_"\$verrel"_all.deb
f=/usr/games/fortune
test -x "\$f"
"\$f"
sudo find / -type f -name '*.changes' -print || true
cd ~
is_ubuntu="${UBUNTU}"
if test "\${is_ubuntu}" = "1"
then
    sudo eatmydata apt-get --no-install-recommends install -y "dput"
    changes_fn=fortune-mod_"\$verrel"_source.changes
    # debsign -k FC112D1F7E444BC8FF95904AFC43A6699C6D49B7 "\${changes_fn}"
    debsign -k "\${key_id}" "\${changes_fn}"
    if false
    then
        dput "\${changes_fn}"
    fi
fi
EOSCRIPTTTTTTT

    $obj->exe_bash_code(
        {
            user => $USER,
            code => $script,
        }
    );
    $obj->docker(
        { cmd => [ 'cp', $obj->container() . ":$HOMEDIR/$LOG_FN", $LOG_FN, ] }
    );
    $obj->docker(
        {
            cmd => [
                'cp',
                $obj->container() . ":$HOMEDIR",
                "ubuntu-docker-results-home-dir",
            ]
        }
    );

}

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

=begin errorreport

Hi! I'm trying to populate a fortune-mod PPA using my fedora40 host system and get an error https://paste.centos.org/view/27585566 "Unknown release release". How can I fix it? I tried duckduckgo, google, reading the source code, reading the man-pages.

=head1 dput output

dput on fedora 40 x86-64 gives me this error. How can I fix it?

shlomif[fortune]:$trunk/scripts/ubuntu-docker-results-home-dir$ dput ppa:shlomif-gmail/fortune-mod fortune-mod_3.22.0-0.1_source.changes
Uploading fortune-mod using ftp to ppa (host: ppa.launchpad.net; directory: ~shlomif-gmail/fortune-mod)
running supported-distribution: check whether the target distribution is currently supported (using distro-info)
{'allowed': ['release'], 'known': ['release', 'proposed', 'updates', 'backports', 'security']}
Unknown release release
⇒ On branch master
⇒ Your branch is up to date with 'origin/master'.
?? ../2del/
?? ../debian-packaging/fortune-mod/
?? ../fortune-mod/
?? ../git-buildpackage-log.txt
?? ../l
?? ./
⇒ Remotes:
origin  git@github.com:shlomif/fortune-mod.git (fetch)
origin  git@github.com:shlomif/fortune-mod.git (push)
=== Reminders ===
Check Facebook for Birthdays
shlomif[fortune]:$trunk/scripts/ubuntu-docker-results-home-dir$


System:
  Host: fedora Kernel: 6.10.9-200.fc40.x86_64 arch: x86_64 bits: 64
  Desktop: Xfce v: 4.18.1 Distro: Fedora Linux 40 (Workstation Edition)
Machine:
  Type: Desktop Mobo: Micro-Star model: MPG B760I EDGE WIFI DDR4 (MS-7D40)
    v: 1.0 serial: <superuser required> UEFI: American Megatrends LLC. v: 1.90
    date: 03/22/2024
CPU:
  Info: 6-core model: 12th Gen Intel Core i5-12400 bits: 64 type: MT MCP
    cache: L2: 7.5 MiB
  Speed (MHz): avg: 800 min/max: 800/4400 cores: 1: 800 2: 800 3: 800 4: 800
    5: 800 6: 800 7: 800 8: 800 9: 800 10: 800 11: 800 12: 800
Graphics:
  Device-1: Intel Alder Lake-S GT1 [UHD Graphics 730] driver: i915 v: kernel
  Display: x11 server: X.Org v: 1.20.14 with: Xwayland v: 24.1.2 driver: X:
    loaded: modesetting unloaded: fbdev,vesa dri: iris gpu: i915
    resolution: 1920x1080~60Hz
  API: OpenGL v: 4.6 vendor: intel mesa v: 24.1.7 renderer: Mesa Intel UHD
    Graphics 730 (ADL-S GT1)
  API: EGL Message: EGL data requires eglinfo. Check --recommends.
Audio:
  Device-1: Intel Raptor Lake High Definition Audio driver: snd_hda_intel
  API: ALSA v: k6.10.9-200.fc40.x86_64 status: kernel-api
  Server-1: PipeWire v: 1.0.7 status: active
Network:
  Device-1: Intel Raptor Lake-S PCH CNVi WiFi driver: iwlwifi
  IF: wlo1 state: down mac: 5a:a8:66:63:9d:00
  Device-2: Realtek RTL8125 2.5GbE driver: r8169
  IF: enp2s0 state: up speed: 1000 Mbps duplex: full mac: 04:7c:16:58:9f:20
Bluetooth:
  Device-1: Intel AX211 Bluetooth driver: btusb type: USB
  Report: btmgmt ID: hci0 state: up address: B0:3C:DC:F7:CF:41 bt-v: 5.3
Drives:
  Local Storage: total: 1.82 TiB used: 592.81 GiB (31.8%)
  ID-1: /dev/nvme0n1 vendor: Kingston model: SFYRD2000G size: 1.82 TiB
Partition:
  ID-1: / size: 195.8 GiB used: 20.06 GiB (10.2%) fs: ext4 dev: /dev/nvme0n1p2
  ID-2: /boot/efi size: 19.99 GiB used: 19.2 MiB (0.1%) fs: vfat
    dev: /dev/nvme0n1p1
  ID-3: /home size: 1.08 TiB used: 572.73 GiB (51.8%) fs: ext4
    dev: /dev/nvme0n1p3
Swap:
  ID-1: swap-1 type: zram size: 8 GiB used: 0 KiB (0.0%) dev: /dev/zram0
Sensors:
  System Temperatures: cpu: 31.0 C mobo: N/A
  Fan Speeds (rpm): N/A
Info:
  Memory: total: 32 GiB note: est. available: 31.12 GiB used: 2.81 GiB (9.0%)
  Processes: 347 Uptime: 1h 2m Shell: gvim inxi: 3.3.34


=end

=cut

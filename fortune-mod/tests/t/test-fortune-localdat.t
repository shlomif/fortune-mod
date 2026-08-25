#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();

use Path::Tiny qw/ cwd path tempdir tempfile /;
use Test::More tests => 1;
use Test::Trap
    qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

sub _chdir_run
{
    my ( $DIR_PATH_NAME, $cb ) = @_;

    my $CWD = Path::Tiny->cwd->absolute;
    chdir($DIR_PATH_NAME);
    my $NEWCWD = Path::Tiny->cwd->absolute;
    $ENV{'PWD'} = $NEWCWD;
    $cb->();
    chdir($CWD);
    $ENV{'PWD'} = $CWD;

    return;
}

# TEST
subtest "local databases" => sub {
    plan tests => 6;
    my $LOCALDIR_suffix = "local/foo";
    my $inst_dir        = FortTestInst::install(
        "fortune-ldatabases-LOCALDIR",
        +{
            LOCALDIR_suffix => $LOCALDIR_suffix,
        }
    );
    my $local_dir = path("$inst_dir/$LOCALDIR_suffix");
    $local_dir->mkdir();
    {
        my $cookiefile_bn   = "testtoast";
        my $cookiefile      = $local_dir->child($cookiefile_bn);
        my @OTHER_BASENAMES = ( "a", "z", "mydb" );
        my $text            = <<"EOF";
This statement is false.
%
The diff between theory and practice is that, in theory, there isn't a diff
between theory and practice, while, in practice, there is.
%
EOF
        $cookiefile->spew_utf8($text);
        _chdir_run(
            $local_dir,
            sub {
                my @cmd;
                foreach my $bn (@OTHER_BASENAMES)
                {
                    my $afile = $local_dir->child($bn);
                    $afile->spew_utf8( map { ( $_ x 50 ), "\n%\n" } 1 .. 9 );
                    @cmd = ( $inst_dir->child( 'bin', 'strfile' ), $afile, );

                    print "Running [@cmd]\n";
                    trap
                    {
                        system(@cmd);
                    };

                    like( $trap->stderr(), qr/\A\r?\n?\z/, "right error." );
                }
                @cmd = ( $inst_dir->child( 'bin', 'strfile' ), $cookiefile, );

                print "Running [@cmd]\n";
                trap
                {
                    system(@cmd);
                };

                like( $trap->stderr(), qr/\A\r?\n?\z/, "right error." );

                @cmd = ( $inst_dir->child( 'games', 'fortune' ), "testtoast", );

                print "Running [@cmd]\n";
                my $ret = -1;
                trap
                {
                    $ret = system(@cmd);
                };

                is( $ret, 0, "fortune exit code." );

                like( $trap->stderr(), qr/\A\r?\n?\z/,
                    "empty stderr; no error." );

                return;
            },
        );
    }
    },
    ;

__END__

=head1 COPYRIGHT & LICENSE

Copyright 2026 by Shlomi Fish

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

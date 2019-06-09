package FortTestInst;

use strict;
use warnings;
our @ISA         = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [qw()] );
our @EXPORT_OK   = ( @{ $EXPORT_TAGS{'all'} } );
our @EXPORT      = qw();
our $VERSION     = '1.00';
require Exporter;

use File::Path qw/mkpath rmtree/;
use Cwd qw/getcwd/;

my $IS_WIN = ( $^O eq "MSWin32" );
my $SEP    = $IS_WIN ? "\\" : '/';
my $MAKE   = $IS_WIN ? 'gmake' : 'make';

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

sub install
{
    my $cwd       = getcwd();
    my $build_dir = "$cwd/fortune-m-build-dir";
    my $inst_dir  = "$cwd/fortune-m-INST_DIR";
    rmtree( $build_dir, 0, 0 );
    rmtree( $inst_dir,  0, 0 );
    mkpath($build_dir);
    chdir $build_dir;
    my $KEY = 'CMAKE_GEN';
    do_system(
        {
            cmd => [
                'cmake',
                ( defined( $ENV{$KEY} ) ? ( "-G", $ENV{$KEY} ) : () ),
                (
                    defined( $ENV{CMAKE_MAKE_PROGRAM} )
                    ? "-DCMAKE_MAKE_PROGRAM=$ENV{CMAKE_MAKE_PROGRAM}"
                    : ()
                ),
                "-DCMAKE_INSTALL_PREFIX=$inst_dir",
                $ENV{SRC_DIR}
            ]
        }
    );
    do_system( { cmd => [$MAKE] } );
    do_system( { cmd => [ $MAKE, 'install', ] } );

    return $inst_dir;
}

1;
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

package FortuneMod_GenManPage_App;

use strict;
use warnings;
use autodie;

use Getopt::Long qw/ GetOptions /;
use Path::Tiny qw/ path tempdir tempfile cwd /;

sub do_system
{
    my ( $self, $args ) = @_;

    my $cmd = $args->{cmd};
    print "Running [@$cmd]\n";
    if ( system(@$cmd) )
    {
        die "Running [@$cmd] failed!";
    }

    return;
}

sub run
{
    my $self = shift;
    my $CMAKE_CURRENT_SOURCE_DIR;
    my $basename;
    GetOptions(
        '--basename=s' => \$basename,
        '--src-dir=s'  => \$CMAKE_CURRENT_SOURCE_DIR,
    ) or die "Wrong options - $!";

    die "missing --src-dir" if ( not $CMAKE_CURRENT_SOURCE_DIR );
    __PACKAGE__->do_system(
        {
            cmd => [
                "docmake", "manpages",
                "${CMAKE_CURRENT_SOURCE_DIR}/util/${basename}.docbook5.xml",
            ],
        },
    );

    path("${CMAKE_CURRENT_SOURCE_DIR}/util/${basename}.man")
        ->spew_utf8( cwd()->child("${basename}.1")->slurp_utf8() =~
            s#^[\t ]+(\.RE|\.PP)[\t ]*$#$1#gmrs =~ s#^[\t ]+$##gmrs =~
            s#\n\n+#\n\n#gmrs );

    return;
}

1;

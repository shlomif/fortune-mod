package FortuneMod::ManPage::Generate::App;

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
    my $dest_basename;
    my $out_basename;
    my $out_section = '1';
    my $subdir      = 'util';
    GetOptions(
        '--basename=s'      => \$basename,
        '--dest-basename=s' => \$dest_basename,
        '--out-basename=s'  => \$out_basename,
        '--out-section=s'   => \$out_section,
        '--src-dir=s'       => \$CMAKE_CURRENT_SOURCE_DIR,
        '--subdir=s'        => \$subdir,
    ) or die "Wrong options - $!";
    $dest_basename = $basename if ( not defined $dest_basename );
    $out_basename  = $basename if ( not defined $out_basename );

    die "missing --src-dir" if ( not $CMAKE_CURRENT_SOURCE_DIR );
    {
        local %ENV = %ENV;
        if ( my $path_prefix = delete( $ENV{DOCMAKE_PATH_PREFIX} ) )
        {
            $ENV{PATH} = $path_prefix . $ENV{PATH};
        }
        __PACKAGE__->do_system(
            {
                cmd => [
                    "docmake",
                    "manpages",
"${CMAKE_CURRENT_SOURCE_DIR}/${subdir}/${basename}.docbook5.xml",
                ],
            },
        );
    }

    path("${CMAKE_CURRENT_SOURCE_DIR}/${subdir}/${dest_basename}.man")
        ->spew_utf8(
        cwd()->child("${out_basename}.${out_section}")->slurp_utf8() =~
            s#^[\t ]+(\.RE|\.PP)[\t ]*$#$1#gmrs =~ s#^[\t ]+$##gmrs =~
            s#\n\n+#\n\n#gmrs );

    return;
}

1;

#!/usr/bin/perl

use strict;
use warnings;
use 5.014;

use FindBin;
use lib "$FindBin::Bin/lib";
use FortTestInst ();

use Path::Tiny qw/ cwd path tempdir tempfile /;
use Test::More tests => 9;
use Test::Trap
    qw( trap $trap :flow:stderr(systemsafe):stdout(systemsafe):warn );

{
    my $inst_dir = FortTestInst::install("fortune-percent-overflow");
    my $IS_WIN   = ( $^O eq "MSWin32" );

    {
        my @cmd = ( $inst_dir->child( 'games', 'fortune' ), "art" );

        print "Running [@cmd]\n";
        trap
        {
            system(@cmd);
        };

        {
            # TEST
            like( $trap->stdout(), qr/\S/ms, "basic test", );

            # TEST
            like( $trap->stderr(), qr/\A\r?\n?\z/ms, "basic test: stderr", );
        }
    }

    my @cmd = (
        $inst_dir->child( 'games', 'fortune' ),
        "999999999999999%", "songs-poems"
    );

    print "Running [@cmd]\n";
    trap
    {
        system(@cmd);
    };

    # TEST
    like( $trap->stderr(),
        qr/Overflow percentage detected at argument "999999999999999%"!/,
        "right error." );

    # TEST
    unlike( $trap->stderr(), qr/-[0-9]/, "negative integer" );
}

{
    my $LOCALDIR_suffix = "local/foo";
    my $inst_dir        = FortTestInst::install(
        "fortune-percent-LOCALDIR",
        +{
            LOCALDIR_suffix => $LOCALDIR_suffix,
        }
    );
    my $local_dir = path("$inst_dir/$LOCALDIR_suffix");
    $local_dir->mkdir();
    my $cookiefile_bn = "jokkkkkkkkkkkes";
    my $datfile_bn    = "$cookiefile_bn.dat";
    my $cookiefile    = $local_dir->child($cookiefile_bn);
    my $datfile       = $local_dir->child($datfile_bn);
    my $text          = <<"EOF";
This statement is false.
%
The diff between theory and practice is that, in theory, there isn't a diff
between theory and practice, while, in practice, there is.
%
EOF
    $cookiefile->spew_utf8($text);
    {
        my @cmd = ( $inst_dir->child( 'bin', 'strfile' ), $cookiefile, );

        print "Running [@cmd]\n";
        trap
        {
            system(@cmd);
        };

        # TEST
        like( $trap->stderr(), qr/\A\r?\n?\z/, "right error." );

    }
    my $IS_WIN = ( $^O eq "MSWin32" );
    {
        my @cmd = ( $inst_dir->child( 'games', 'fortune' ), "70%", "all" );

        print "Running [@cmd]\n";
        trap
        {
            system(@cmd);
        };

        {
            # TEST
            like(
                $trap->stderr(),
                qr/fortune: no place to put residual probability/ms,
"percent overflow: https://github.com/shlomif/fortune-mod/issues/79 [all percent when local+system dirs have fortunes]"
            );

            # TEST
            unlike(
                $trap->stderr(),
                qr/[pP]robabilities sum to 140\%/,
"percent overflow: https://github.com/shlomif/fortune-mod/issues/79 [all percent when local+system dirs have fortunes]"
            );
        }
    }

    {
        my @cmd = ( $inst_dir->child( 'games', 'fortune' ), "art" );

        print "Running [@cmd]\n";
        trap
        {
            system(@cmd);
        };

        {
            # TEST
            like( $trap->stdout(), qr/\S/ms, "basic test", );

            # TEST
            like( $trap->stderr(), qr/\A\r?\n?\z/ms, "basic test: stderr", );
        }
    }
}

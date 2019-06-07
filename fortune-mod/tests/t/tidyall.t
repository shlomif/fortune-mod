package main;

use strict;
use warnings;

use Test::More;
my $SKIP_KEY = 'FORTUNE_TEST_TIDY';
if ( !$ENV{$SKIP_KEY} )
{
    plan skip_all => "Skipping because $SKIP_KEY is not set";
}

package MyCacheModel;

require Moo;
Moo->import;

extends('Code::TidyAll::CacheModel');

my $DUMMY_LAST_MOD = 0;

sub _build_cache_value
{
    my ($self) = @_;

    return $self->_sig(
        [ $self->base_sig, $DUMMY_LAST_MOD, $self->file_contents ] );
}

package main;
require Test::Code::TidyAll;

my $KEY = 'TIDYALL_DATA_DIR';
Test::Code::TidyAll::tidyall_ok(
    conf_file         => "$ENV{SRC_DIR}/.tidyallrc",
    cache_model_class => 'MyCacheModel',
    ( exists( $ENV{$KEY} ) ? ( data_dir => $ENV{$KEY} ) : () )
);

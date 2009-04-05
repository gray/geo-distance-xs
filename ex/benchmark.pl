#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark qw(cmpthese timethese);
use Geo::Distance;

my @coord = (-118.243103, 34.159545, -73.987427, 40.853293);

my $geo = Geo::Distance->new;
sub geo {
    my $d = $geo->distance(mile => @coord)
};

# Need this mess so timethese can be used.
{
    my $orig_timethis_sub = \&Benchmark::timethis;
    no warnings 'redefine';
    *Benchmark::timethis = sub {
        if ($_[2] eq 'xs') {
            eval 'use Geo::Distance::XS';
            *Benchmark::timethis = $orig_timethis_sub;
        }
        $orig_timethis_sub->(@_);            
    };
}

my $benchmarks = timethese -1, {
    perl => \&geo,
    xs   => \&geo,
};

cmpthese $benchmarks;

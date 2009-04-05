#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark qw(cmpthese timethis);
use Geo::Distance;

my @coord = (-118.243103, 34.159545, -73.987427, 40.853293);

my $geo = Geo::Distance->new;

sub geo {
    $geo->distance(mile => @coord);
}

my %benchmarks;
$benchmarks{perl} = timethis -1, \&geo, '', 'none';

require Geo::Distance::XS;

$benchmarks{xs} = timethis -1, \&geo, '', 'none';

cmpthese  \%benchmarks;

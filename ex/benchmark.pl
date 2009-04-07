#!/usr/bin/env perl
use strict;
use warnings;

use Benchmark qw(cmpthese timethese);
use Geo::Distance::XS;

# When benchmarking, need to have it call import/unimport before the
# code is executed.
my $orig_timethis_sub = \&Benchmark::timethis;
{
    no warnings 'redefine';
    *Benchmark::timethis = sub {
        my $sub = ('perl' eq $_[2] ? 'un' : '') . 'import';
        Geo::Distance::XS->$sub();
        $orig_timethis_sub->(@_);
    };
}

my @coord = (-118.243103, 34.159545, -73.987427, 40.853293);

my $geo = Geo::Distance->new;

sub geo {
    my $d = $geo->distance(mile => @coord);
}

for my $formula (qw(hsin polar cos gcd mt tv)) {
    print "---- [ Formula: $formula ] ------------------------------------\n";

    $geo->formula($formula);

    Geo::Distance::XS->unimport;
    printf "perl - distance from LA to NY: %s miles\n", geo();
    Geo::Distance::XS->import;
    printf "xs   - distance from LA to NY: %s miles\n", geo();
    print "\n";

    my $benchmarks = timethese -1, {
        perl => \&geo,
        xs   => \&geo,
    };

    cmpthese $benchmarks;
    print "\n";
}

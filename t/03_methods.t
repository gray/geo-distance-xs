use strict;
use warnings;
use Geo::Distance::XS;
use Test::More tests => 1;

my $geo = Geo::Distance->new;

my @coords = (-118.243103, 34.159545, -73.987427, 40.853293);
my $distance = $geo->distance(mile => @coords);

is(int $distance, 2443, 'distance from LA to NY');

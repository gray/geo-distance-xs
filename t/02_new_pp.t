use strict;
use warnings;
use Test::More;

use Geo::Distance;

my $version = $Geo::Distance::VERSION || 0;

plan skip_all => 'Geo::Distance between 0.16 and 0.20 is not installed.'
    unless $version >= 0.16 and $version <= 0.20;

# Tests that Geo::Distance automatically loads the XS version.
my $geo = Geo::Distance->new;
is defined $Geo::Distance::XS::VERSION, 1, 'PP version loads XS';

done_testing;

use strict;
use warnings;
use Test::More tests => 2;

eval "use Geo::Distance 0.16; 1" or do {
    plan skip_all => 'Geo::Distance >= 0.16 is not installed.';
};

my $geo = Geo::Distance->new;

is(defined $Geo::Distance::XS::VERSION, 1, 'xs $VERSION defined');

is(
    defined &Geo::Distance::XS::_distance_hsin, 1,
    'XS::_distance_hsin defined'
);

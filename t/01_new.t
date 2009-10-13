use strict;
use warnings;
use Geo::Distance::XS;
use Test::More tests => 3;

my $geo = Geo::Distance->new;
isa_ok($geo, 'Geo::Distance', 'new');
can_ok('Geo::Distance', qw(distance formula));
can_ok('Geo::Distance::XS', qw(
    _distance_hsin _distance_cos _distance_polar _distance_gcd _distance_tv
));

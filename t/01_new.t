use strict;
use warnings;
use Test::More tests => 2;
use Geo::Distance::XS;

my $geo = Geo::Distance->new;
isa_ok($geo, 'Geo::Distance', 'new');
can_ok('Geo::Distance', qw(distance));

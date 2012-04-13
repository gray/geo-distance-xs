use strict;
use warnings;
use Geo::Distance::XS;
use Test::More;

my $geo = Geo::Distance->new;
isa_ok $geo, 'Geo::Distance', 'new';
can_ok 'Geo::Distance', qw(distance formula);
ok defined @Geo::Distance::XS::FORMULAS;
cmp_ok scalar @Geo::Distance::XS::FORMULAS, '>', 2;

done_testing;

package Geo::Distance::XS;

use strict;
use warnings;

use Carp qw(croak);
use Geo::Distance;
use XSLoader;

our $VERSION    = '0.09';
our $XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

XSLoader::load(__PACKAGE__, $XS_VERSION);

my ($orig_distance_sub, $orig_formula_sub);
BEGIN {
    $orig_distance_sub = \&Geo::Distance::distance;
    $orig_formula_sub  = \&Geo::Distance::formula;
}

sub import {
    no warnings qw(redefine);

    our @FORMULAS = qw( cos gcd hsin mt polar tv );
    my %formulas = map { $_ => \&{"_distance_$_"} } @FORMULAS;

    # TODO: move this into XS.
    *Geo::Distance::distance = sub { &{$formulas{$_[0]->{formula}}} };

    *Geo::Distance::formula = sub {
        my $self = shift;
        if (@_) {
            my $formula = shift;
            croak "Invalid formula: $formula" unless $formulas{$formula};
            $self->{formula} = $formula;
        }
        return $self->{formula};
    };
}

# Fall back to pure perl after calling 'no Geo::Distance::XS'.
sub unimport {
    no warnings qw(redefine);

    *Geo::Distance::formula  = $orig_formula_sub;
    *Geo::Distance::distance = $orig_distance_sub;
}


1;

__END__

=head1 NAME

Geo::Distance::XS - speed up Geo::Distance

=head1 SYNOPSIS

    use Geo::Distance::XS;

    my $geo = Geo::Distance->new;
    my $distance = $geo->distance(mile => $lon1, $lat1 => $lon2, $lat2);

=head1 DESCRIPTION

The C<Geo::Distance::XS> module provides faster C implementations of the
distance calculations found in C<Geo::Distance>.  See the documentation for
that module for usage.

NOTE: As of version 0.13, Geo::Distance automatically uses this module if
it is installed.

=head1 PERFORMANCE

This distribution contains a benchmarking script which compares
C<Geo::Distance::XS> with C<Geo::Distance> and C<GIS::Distance::Fast>.
These are the results on a MacBook 2GHz with Perl 5.12.2:

    ---- [ Formula: hsin ] ------------------------------------
    perl     - distance from LA to NY: 2443.08796228363 miles
    xs       - distance from LA to NY: 2443.08796228363 miles
    gis_fast - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  1 wallclock secs ( 1.06 usr +  0.01 sys =  1.07 CPU) @ 23642.99/s (n=25298)
        perl:  1 wallclock secs ( 1.11 usr +  0.00 sys =  1.11 CPU) @ 77490.99/s (n=86015)
            xs:  1 wallclock secs ( 1.00 usr +  0.01 sys =  1.01 CPU) @ 1238753.47/s (n=1251141)
                Rate gis_fast     perl       xs
    gis_fast   23643/s       --     -69%     -98%
    perl       77491/s     228%       --     -94%
    xs       1238753/s    5139%    1499%       --

    ---- [ Formula: polar ] ------------------------------------
    perl     - distance from LA to NY: 2766.02509696782 miles
    xs       - distance from LA to NY: 2766.02509696782 miles
    gis_fast - distance from LA to NY: 2766.02509696782 miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  1 wallclock secs ( 1.14 usr + -0.01 sys =  1.13 CPU) @ 19029.20/s (n=21503)
        perl:  1 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 80387.85/s (n=86015)
            xs:  2 wallclock secs ( 1.12 usr + -0.01 sys =  1.11 CPU) @ 1458670.27/s (n=1619124)
                Rate gis_fast     perl       xs
    gis_fast   19029/s       --     -76%     -99%
    perl       80388/s     322%       --     -94%
    xs       1458670/s    7565%    1715%       --

    ---- [ Formula: cos ] ------------------------------------
    perl     - distance from LA to NY: 2443.08796228363 miles
    xs       - distance from LA to NY: 2443.08796228363 miles
    gis_fast - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 23866.04/s (n=25298)
        perl:  1 wallclock secs ( 1.03 usr +  0.00 sys =  1.03 CPU) @ 75918.45/s (n=78196)
            xs:  2 wallclock secs ( 1.07 usr +  0.01 sys =  1.08 CPU) @ 1279826.85/s (n=1382213)
                Rate gis_fast     perl       xs
    gis_fast   23866/s       --     -69%     -98%
    perl       75918/s     218%       --     -94%
    xs       1279827/s    5263%    1586%       --

    ---- [ Formula: gcd ] ------------------------------------
    perl     - distance from LA to NY: 12438.0476860875-9076.08896733252i miles
    xs       - distance from LA to NY: 2443.08796228363 miles
    gis_fast - distance from LA to NY: 12438.0476860875-9076.08896733252i miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  2 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 4185.98/s (n=4479)
        perl:  1 wallclock secs ( 1.06 usr +  0.00 sys =  1.06 CPU) @ 6339.62/s (n=6720)
            xs:  2 wallclock secs ( 1.05 usr +  0.00 sys =  1.05 CPU) @ 1310719.05/s (n=1376255)
                Rate gis_fast     perl       xs
    gis_fast    4186/s       --     -34%    -100%
    perl        6340/s      51%       --    -100%
    xs       1310719/s   31212%   20575%       --

    ---- [ Formula: mt ] ------------------------------------
    perl     - distance from LA to NY: 2443.08796228363 miles
    xs       - distance from LA to NY: 2443.08796228363 miles
    gis_fast - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  1 wallclock secs ( 1.13 usr +  0.01 sys =  1.14 CPU) @ 17148.25/s (n=19549)
        perl:  1 wallclock secs ( 1.07 usr +  0.01 sys =  1.08 CPU) @ 66370.37/s (n=71680)
            xs:  0 wallclock secs ( 1.07 usr +  0.01 sys =  1.08 CPU) @ 1274310.19/s (n=1376255)
                Rate gis_fast     perl       xs
    gis_fast   17148/s       --     -74%     -99%
    perl       66370/s     287%       --     -95%
    xs       1274310/s    7331%    1820%       --

    ---- [ Formula: tv ] ------------------------------------
    perl     - distance from LA to NY: 2448.24135235512 miles
    xs       - distance from LA to NY: 2443.80013146211 miles
    gis_fast - distance from LA to NY: 2448.24135235512 miles

    Benchmark: running gis_fast, perl, xs for at least 1 CPU seconds...
    gis_fast:  1 wallclock secs ( 1.05 usr +  0.01 sys =  1.06 CPU) @ 21353.77/s (n=22635)
        perl:  1 wallclock secs ( 1.13 usr +  0.01 sys =  1.14 CPU) @ 15719.30/s (n=17920)
            xs:  1 wallclock secs ( 1.04 usr +  0.00 sys =  1.04 CPU) @ 778425.00/s (n=809562)
                Rate     perl gis_fast       xs
    perl      15719/s       --     -26%     -98%
    gis_fast  21354/s      36%       --     -97%
    xs       778425/s    4852%    3545%       --

=head1 SEE ALSO

L<Geo::Distance>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to
L<http://rt.cpan.org/Public/Bug/Report.html?Queue=Geo-Distance-XS>. I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geo::Distance::XS

You can also look for information at:

=over

=item * GitHub Source Repository

L<http://github.com/gray/geo-distance-xs>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-Distance-XS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Geo-Distance-XS>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/Public/Dist/Display.html?Name=Geo-Distance-XS>

=item * Search CPAN

L<http://search.cpan.org/dist/Geo-Distance-XS/>

=back

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2012 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut

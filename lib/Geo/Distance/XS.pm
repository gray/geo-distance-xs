package Geo::Distance::XS;

use strict;
use warnings;

our $VERSION = '0.04';

eval {
    require XSLoader;
    XSLoader::load(__PACKAGE__, $VERSION);
    1;
} or do {
    require DynaLoader;
    DynaLoader::bootstrap(__PACKAGE__, $VERSION);
};

use Geo::Distance;

my ($orig_distance_sub, $orig_formula_sub);
BEGIN {
    $orig_distance_sub = \&Geo::Distance::distance;
    $orig_formula_sub  = \&Geo::Distance::formula;
}

sub import {
    no warnings qw(redefine);

    # Ensure the formula type is the same before and after import is called.
    *Geo::Distance::distance = sub {
        *Geo::Distance::distance = \&{'_distance_' . $_[0]->{formula}};
        Geo::Distance::distance(@_);
    };

    *Geo::Distance::formula = sub {
        $orig_formula_sub->(@_);
        *Geo::Distance::distance = \&{'_distance_' . $_[0]->{formula}};
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
C<Geo::Distance::XS> with C<Geo::Distance>.  These are the results on a
MacBook 2GHz with Perl 5.8.9:

    ---- [ Formula: hsin ] ------------------------------------
    perl - distance from LA to NY: 2443.08796228363 miles
    xs   - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  1 wallclock secs ( 1.09 usr +  0.01 sys =  1.10 CPU) @ 65162.73/s (n=71679)
            xs:  2 wallclock secs ( 1.11 usr +  0.02 sys =  1.13 CPU) @ 936865.49/s (n=1058658)
            Rate  perl    xs
    perl  65163/s    --  -93%
    xs   936865/s 1338%    --

    ---- [ Formula: polar ] ------------------------------------
    perl - distance from LA to NY: 2766.02509696782 miles
    xs   - distance from LA to NY: 2766.02509696782 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  1 wallclock secs ( 1.05 usr +  0.01 sys =  1.06 CPU) @ 67621.70/s (n=71679)
            xs:  0 wallclock secs ( 1.06 usr + -0.00 sys =  1.06 CPU) @ 1180321.70/s (n=1251141)
            Rate  perl    xs
    perl   67622/s    --  -94%
    xs   1180322/s 1645%    --

    ---- [ Formula: cos ] ------------------------------------
    perl - distance from LA to NY: 2443.08796228363 miles
    xs   - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  1 wallclock secs ( 1.02 usr +  0.01 sys =  1.03 CPU) @ 64238.83/s (n=66166)
            xs:  2 wallclock secs ( 1.05 usr +  0.01 sys =  1.06 CPU) @ 927395.28/s (n=983039)
            Rate  perl    xs
    perl  64239/s    --  -93%
    xs   927395/s 1344%    --

    ---- [ Formula: gcd ] ------------------------------------
    perl - distance from LA to NY: 12438.0476860875-9076.08896733252i miles
    xs   - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  2 wallclock secs ( 1.06 usr +  0.01 sys =  1.07 CPU) @ 5910.28/s (n=6324)
            xs:  0 wallclock secs ( 1.07 usr +  0.00 sys =  1.07 CPU) @ 918728.04/s (n=983039)
            Rate   perl     xs
    perl   5910/s     --   -99%
    xs   918728/s 15445%     --

    ---- [ Formula: mt ] ------------------------------------
    perl - distance from LA to NY: 2443.08796228363 miles
    xs   - distance from LA to NY: 2443.08796228363 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  1 wallclock secs ( 1.07 usr +  0.01 sys =  1.08 CPU) @ 56887.96/s (n=61439)
            xs:  2 wallclock secs ( 0.99 usr +  0.01 sys =  1.00 CPU) @ 917503.00/s (n=917503)
            Rate  perl    xs
    perl  56888/s    --  -94%
    xs   917503/s 1513%    --

    ---- [ Formula: tv ] ------------------------------------
    perl - distance from LA to NY: 2448.24135235512 miles
    xs   - distance from LA to NY: 2443.80013146211 miles

    Benchmark: running perl, xs for at least 1 CPU seconds...
        perl:  2 wallclock secs ( 1.05 usr +  0.01 sys =  1.06 CPU) @ 13523.58/s (n=14335)
            xs:  0 wallclock secs ( 1.05 usr + -0.01 sys =  1.04 CPU) @ 601509.62/s (n=625570)
            Rate  perl    xs
    perl  13524/s    --  -98%
    xs   601510/s 4348%    --

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

Copyright (C) 2009 gray <gray at cpan.org>, all rights reserved.

This library is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=head1 AUTHOR

gray, <gray at cpan.org>

=cut

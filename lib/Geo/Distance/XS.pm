package Geo::Distance::XS;

use strict;
use warnings;

our $VERSION = '0.01';

eval {
    require XSLoader;
    XSLoader::load(__PACKAGE__, $VERSION);
    1;
} or do {
    require DynaLoader;
    DynaLoader::bootstrap(__PACKAGE__, $VERSION);
};

use Geo::Distance;

no warnings qw(redefine);

my $orig_distance_sub = \&Geo::Distance::distance;
*Geo::Distance::distance = \&distance_hsin;

# Avoids checking the formula type on every call to distance.
my $orig_formula_sub = \&Geo::Distance::formula;
*Geo::Distance::formula = sub {
    $orig_formula_sub->(@_);
    *Geo::Distance::distance = \&{'distance_' . $_[0]->{formula}};
};

# Fall back to pure perl after calling 'no use Geo::Distance::XS'.
sub unimport {
    *Geo::Distance::formula = $orig_formula_sub;
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

=head1 PERFORMANCE

This distribution contains a benchmarking script which compares
C<Geo::Distance::XS> with C<Geo::Distance>.  These are the results on a
MacBook 2GHz with Perl 5.8.9:

    Benchmark: running perl, xs for at least 1 CPU seconds...
          perl:  1 wallclock secs ( 1.09 usr +  0.01 sys =  1.10 CPU) @ 65162.73/s (n=71679)
            xs:  0 wallclock secs ( 1.12 usr + -0.01 sys =  1.11 CPU) @ 953745.95/s (n=1058658)
             Rate  perl    xs
    perl  65163/s    --  -93%
    xs   953746/s 1364%    --

=head1 SEE ALSO

L<Geo::Distance>

=head1 REQUESTS AND BUGS

Please report any bugs or feature requests to 
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geo-Distance-XS>. I will be
notified, and then you'll automatically be notified of progress on your bug as
I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geo::Distance::XS

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-Distance-XS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Geo-Distance-XS>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-Distance-XS>

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

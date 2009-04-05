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

require Geo::Distance;
no warnings qw(redefine);

*Geo::Distance::distance = sub {
    my($self,$unit,$lon1,$lat1,$lon2,$lat2) = @_;
    croak('Unkown unit type "'.$unit.'"') unless($unit = $self->{units}->{$unit});
    return $unit * hsin($lat1, $lon1, $lat2, $lon2);
};


1;

__END__

=head1 NAME

Geo::Distance::XS - speed up Geo::Distance

=head1 SYNOPSIS

    use Geo::Distance::XS;

    my $geo = Geo::Distance->new;
    my $distance = $geo->distance(mile => $lon1, $lat1 => $lon2, $lat2);

=head1 DESCRIPTION

The C<Geo::Distance::XS> module provides a faster implementation of the
distance calculations in C.

This module is a subclass of C<Geo::Distance>- refer to the documentation
for that module.

=head1 PERFORMANCE

This distribution contains a benchmarking script which compares
C<Geo::Distance::XS> with C<Geo::Distance>.  These are the results on a
MacBook 2GHz with Perl 5.8.9:

             Rate perl   xs
    perl  67622/s   -- -81%
    xs   360654/s 433%   --

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

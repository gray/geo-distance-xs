#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "math.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846264338327950288
#endif
#ifndef M_PI_2
#define M_PI_2 1.57079632679489661923132169163975144
#endif

const double DEG_RADS = M_PI / 180.0;

double haversine (double lat1, double lon1, double lat2, double lon2) {
    double dlon = (lon2 - lon1) * DEG_RADS;
    double dlat = (lat2 - lat1) * DEG_RADS;
    double a = pow(sin(dlat / 2), 2) + cos(lat1 * DEG_RADS) *
               cos(lat2 * DEG_RADS) * pow(sin(dlon / 2), 2);
    double d = 2 * atan2(sqrt(a), sqrt(1 - a));
    return d;
}

double cosines (double lat1, double lon1, double lat2, double lon2) {
    lon1 = lon1 * DEG_RADS;
    lat1 = lat1 * DEG_RADS;
    lon2 = lon2 * DEG_RADS;
    lat2 = lat2 * DEG_RADS;
    double a = sin(lat1) * sin(lat2);
    double b = cos(lat1) * cos(lat2) * cos(lon2 - lon1);
    double d = acos(a + b);
    return d;
}

double polar (double lat1, double lon1, double lat2, double lon2) {
    double a = M_PI_2 - lat1 * DEG_RADS;
    double b = M_PI_2 - lat1 * DEG_RADS;
    double d = sqrt(pow(a, 2) + pow(b, 2) - 2 * a * b * cos(lon2 - lon1));
    return d;
}

double great_circle (double lat1, double lon1, double lat2 , double lon2) {
    double dlon = (lon1 - lon2) * DEG_RADS;
    double dlat = (lat1 - lat2) * DEG_RADS;
    double a = pow(sin(dlat / 2), 2) + cos(lat1 * DEG_RADS) *
               cos(lat2 * DEG_RADS) * pow(sin(dlon / 2), 2);
    double d = 2 * asin(sqrt(a));
    return d;
}

double vincenty (double lat1, double lon1, double lat2 , double lon2) {
    double d = 1.0;
    return d;
}

/* TODO: add more guards against unexpected data */
double _count_units (SV *self, SV *unit) {
    dTHX;

    STRLEN len;
    char *name = SvPV(unit, len);

    SV **svp = hv_fetchs((HV*)SvRV(self), "units", 0);
    if (! svp) croak("Unknown unit type \"%s\"", unit);

    HV *hash = (HV *)SvRV(*svp);
    svp = hv_fetch(hash, name, len, 0);
    if (! svp) croak("Unknown unit type \"%s\"", unit);

    return SvNV(*svp);
}


MODULE = Geo::Distance::XS    PACKAGE = Geo::Distance::XS

PROTOTYPES: DISABLE

NV
distance_hsin (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
CODE:
    XSRETURN_NV(_count_units(self, unit) * haversine(lat1, lon1, lat2, lon2));

NV
distance_cos (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
ALIAS:
    distance_mt = 1
CODE:
    XSRETURN_NV(_count_units(self, unit) * cosines(lat1, lon1, lat2, lon2));

NV
distance_polar (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
CODE:
    XSRETURN_NV(_count_units(self, unit) * polar(lat1, lon1, lat2, lon2));

NV
distance_gcd (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
CODE:
    XSRETURN_NV(_count_units(self, unit) *
                great_circle(lat1, lon1, lat2, lon2));

NV
distance_tv (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
CODE:
    XSRETURN_NV(_count_units(self, unit) * vincenty(lat1, lon1, lat2, lon2));

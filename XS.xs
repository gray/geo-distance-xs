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

const double DEG_RADS = M_PI / 180.;

static void
my_croak (char* pat, ...) {
    va_list args;
    SV *error_sv;

    dTHX;
    dSP;

    error_sv = newSV(0);

    va_start(args, pat);
    sv_vsetpvf(error_sv, pat, &args);
    va_end(args);

    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(sv_2mortal(error_sv));
    PUTBACK;
    call_pv("Carp::croak", G_VOID | G_DISCARD);
    FREETMPS;
    LEAVE;
}

double
haversine (double lat1, double lon1, double lat2, double lon2) {
    lat1 *= DEG_RADS; lon1 *= DEG_RADS;
    lat2 *= DEG_RADS; lon2 *= DEG_RADS;
    double a = pow(sin((lat2 - lat1) / 2.), 2.) + cos(lat1) *
               cos(lat2) * pow(sin((lon2 - lon1) / 2.), 2.);
    double d = 2. * atan2(sqrt(a), sqrt(fabs(1. - a)));
    return d;
}

double
cosines (double lat1, double lon1, double lat2, double lon2) {
    lat1 *= DEG_RADS; lon1 *= DEG_RADS;
    lat2 *= DEG_RADS; lon2 *= DEG_RADS;
    double a, b, d;
    a = sin(lat1) * sin(lat2);
    b = cos(lat1) * cos(lat2) * cos(lon2 - lon1);
    d = acos(a + b);
    /* Antipodal coordinates result in NaN */
    if (isnan(d))
        return haversine(lat1, lon1, lat2, lon2);
    return d;
}

double
polar (double lat1, double lon1, double lat2, double lon2) {
    double a = M_PI_2 - lat1 * DEG_RADS;
    double b = M_PI_2 - lat2 * DEG_RADS;
    double dlon = (lon2 - lon1) * DEG_RADS;
    double d = sqrt(pow(a, 2.) + pow(b, 2.) - 2. * a * b * cos(dlon));
    return d;
}

double
great_circle (double lat1, double lon1, double lat2 , double lon2) {
    lat1 *= DEG_RADS; lon1 *= DEG_RADS;
    lat2 *= DEG_RADS; lon2 *= DEG_RADS;
    double a = pow(sin((lat2 - lat1) / 2.), 2.) + cos(lat1) *
               cos(lat2) * pow(sin((lon2 - lon1) / 2.), 2.);
    double d = 2. * asin(sqrt(a));
    return d;
}

double
vincenty (double lat1, double lon1, double lat2 , double lon2) {
    const double MAJOR_RADIUS = 6378137. / 6370997.;
    const double MINOR_RADIUS = 6356752.3142 / 6370997.;
    const double FLATTENING = (MAJOR_RADIUS - MINOR_RADIUS) / MAJOR_RADIUS;

    double dlon = (lon2 - lon1) * DEG_RADS;
    double u1 = atan((1. - FLATTENING) * tan(lat1 * DEG_RADS));
    double u2 = atan((1. - FLATTENING) * tan(lat2 * DEG_RADS));
    double sin_u1 = sin(u1), cos_u1 = cos(u1);
    double sin_u2 = sin(u2), cos_u2 = cos(u2);

    double lambda = dlon, lambda_p = 2. * M_PI;
    int iter_limit = 100;

    double sin_sigma, cos_sigma;
    double sigma;
    double cos_sq_alpha, cos_sigma_m;
    double u_sq, a, b, delta_sigma, d;

    while (fabs(lambda - lambda_p) > 1e-12 && iter_limit-- > 0) {
        double alpha, c;
        double sin_lambda = sin(lambda);
        double cos_lambda = cos(lambda);
        sin_sigma = sqrt((cos_u2 * sin_lambda) * (cos_u2 * sin_lambda) +
                         (cos_u1 * sin_u2 - sin_u1 * cos_u2 * cos_lambda) *
                         (cos_u1 * sin_u2-sin_u1 * cos_u2 * cos_lambda));
        if (sin_sigma == 0.) {
            return 0.;
        }
        cos_sigma = sin_u1 * sin_u2 + cos_u1 * cos_u2 * cos_lambda;
        sigma = atan2(sin_sigma, cos_sigma);
        alpha = asin(cos_u1 * cos_u2 * sin_lambda / sin_sigma);
        cos_sq_alpha = cos(alpha) * cos(alpha);
        cos_sigma_m = cos_sigma - 2. * sin_u1 * sin_u2 / cos_sq_alpha;
        if (isnan(cos_sigma_m)) {
            cos_sigma_m = 0.;
        }
        c = FLATTENING / 16. * cos_sq_alpha *
            (4. + FLATTENING * (4. - 3. * cos_sq_alpha));
        lambda_p = lambda;
        lambda = dlon + (1. - c) * FLATTENING * sin(alpha) * (sigma + c *
                 sin_sigma * (cos_sigma_m + c * cos_sigma * (-1. + 2. *
                 cos_sigma_m * cos_sigma_m)));
    }
    if (! iter_limit)
        return 0.;

    u_sq = cos_sq_alpha * (MAJOR_RADIUS * MAJOR_RADIUS - MINOR_RADIUS *
           MINOR_RADIUS) / (MINOR_RADIUS * MINOR_RADIUS);
    a = 1. + u_sq / 16384. * (4096. + u_sq * (-768. + u_sq *
               (320. - 175. * u_sq)));
    b = u_sq / 1024. * (256. + u_sq * (-128. + u_sq * (74. - 47. * u_sq)));
    delta_sigma = b * sin_sigma * (cos_sigma_m + b / 4 * (cos_sigma *
                  (-1. + 2. * cos_sigma_m * cos_sigma_m) - b / 6. *
                  cos_sigma_m * (- 3. + 4. * sin_sigma * sin_sigma) *
                  (-3. + 4. * cos_sigma_m * cos_sigma_m)));
    d = MINOR_RADIUS * a * (sigma - delta_sigma);
    return d;
}

/* TODO: add more guards against unexpected data */
double
_count_units (SV *self, SV *unit) {
    dTHX;

    STRLEN len;
    char *name = SvPV(unit, len);
    HV *hash;

    SV **svp = hv_fetchs((HV *)SvRV(self), "units", 0);
    if (! svp) my_croak("Unknown unit type \"%s\"", name);

    hash = (HV *)SvRV(*svp);
    svp = hv_fetch(hash, name, len, 0);
    if (! svp) my_croak("Unknown unit type \"%s\"", name);

    return SvNV(*svp);
}

MODULE = Geo::Distance::XS    PACKAGE = Geo::Distance::XS

PROTOTYPES: DISABLE

void
_distance_hsin (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
PPCODE:
    XSRETURN_NV(_count_units(self, unit) * haversine(lat1, lon1, lat2, lon2));

void
_distance_cos (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
ALIAS:
    _distance_mt = 1
PPCODE:
    XSRETURN_NV(_count_units(self, unit) * cosines(lat1, lon1, lat2, lon2));

void
_distance_polar (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
PPCODE:
    XSRETURN_NV(_count_units(self, unit) * polar(lat1, lon1, lat2, lon2));

void
_distance_gcd (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
PPCODE:
    XSRETURN_NV(_count_units(self, unit) *
                great_circle(lat1, lon1, lat2, lon2));

void
_distance_tv (self, unit, lon1, lat1, lon2, lat2)
    SV *self
    SV *unit
    NV lon1
    NV lat1
    NV lon2
    NV lat2
PPCODE:
    XSRETURN_NV(_count_units(self, unit) * vincenty(lat1, lon1, lat2, lon2));

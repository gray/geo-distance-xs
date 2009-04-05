#define PERL_NO_GET_CONTEXT

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "math.h"

double deg2rad(double deg) {
    return (deg * (M_PI / 180.0));
}

double _cosines(double lat1, double lon1, double lat2, double lon2) {
    lon1 = deg2rad(lon1);
    lat1 = deg2rad(lat1);
    lon2 = deg2rad(lon2);
    lat2 = deg2rad(lat2);

    double a = sin(lat1) * sin(lat2);
    double b = cos(lat1) * cos(lat2) * cos(lon2 - lon1);
    double c = acos(a + b);

    return c;
}

double _haversine(double lat1, double lon1, double lat2, double lon2) {
    double dlon = deg2rad(lon2 - lon1);
    double dlat = deg2rad(lat2 - lat1);
    double a = pow(sin(dlat/2), 2) + cos(deg2rad(lat1)) *
               cos(deg2rad(lat2)) * pow(sin(dlon/2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1-a));

    return c;
}

double _euclidian(double lat1, double lon1, double lat2 , double lon2) {
  double c = sqrt(pow(deg2rad(lat2 - lat1), 2) +
                  pow(deg2rad(lon2 - lon1), 2));
  return c;
}


MODULE = Geo::Distance::XS    PACKAGE = Geo::Distance::XS

PROTOTYPES: DISABLE

NV
hsin (lat1, lon1, lat2, lon2)
    NV lat1
    NV lon1
    NV lat2
    NV lon2
PPCODE:
    XSRETURN_NV(_haversine(lat1, lon1, lat2, lon2));

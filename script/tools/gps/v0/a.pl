#!/usr/bin/perl
#

use Geo::Coordinates::UTM;

my($name, $r, $sqecc) = ellipsoid_info 'WGS-84';

($east,$north)=utm_to_latlon('WGS-84',"30T",440529.79,6552524.00);
print "A-$east-$north\n";


($zone,$east,$north)=latlon_to_utm(23,46.0201,-0.3374);
print "B-$zone-$east-$north\n";
($east,$north)=utm_to_latlon('WGS-84',"30T",-706094.062248025,5099727.84793006);
print "C-$east-$north\n";

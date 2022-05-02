#!/usr/bin/perl

  use strict;
  use Geo::Proj4;

  #my $proj = Geo::Proj4->new( proj => "lcc", ellps => "clrk80", init => "epsg:27572");
# , datum => NTF (Paris));
  
  #my $proj = Geo::Proj4->new(init => "epsg:27572");
  my $from  = Geo::Proj4->new("+proj=latlong +datum=NAD83");
  my $to    = Geo::Proj4->new("proj +proj=lcc +lat_1=46.8 +lat_0=46.8 +lon_0=2.33722917 +k_0=0.99987742 +x_0=600000 +y_0=2200000 +a=6378249.2 +b=6356515 +pm=paris +units=m +no_defs -S -r");
 
  my $lat = 48.816667;
  my $long = 2.266667;
 
  my ($x, $y) = $proj->forward($lat, $long);
  print "conversion to LAMBERT II : y is  $y\n";
  print "conversion to LAMBERT II : x is  $x\n";

  my ($lat, $long) = $proj->inverse($x, $y);
  print "inverse conversion: lat is $lat \n" ;
  print "inverse conversion: long is $long \n" ;

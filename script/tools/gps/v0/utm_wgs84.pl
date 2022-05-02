#!/usr/bin/perl
#*****************************************************************************
#
# Copyright (c) 2003 Guillaume Cottenceau <guillaume.cottenceau at free.fr>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#******************************************************************************
#
# Based on Geoconv Java code by Johan Montagnat <johan at creatis.insa-lyon.fr>
#

use Math::Trig;

our $debug;

sub printd {
    $debug and print @_;
}


#- UTM uses a GRS80 ellipsoid
my $a = 6378137;
my $b = 6356752.314;
my $e = sqrt(($a*$a - $b*$b) / ($a*$a));

#- false east in meters (constant)
my $Xs = 500000;


sub utm_to_wgs84 {
    my ($zone, $isnorth, $x, $y) = @_;

    my $east = $x;
    my $north = $y;

    #- false north in meters (0 in northern hemisphere, 10000000 in southern hemisphere)
    my $Ys = ($isnorth =~ /^s/i || ($isnorth =~ /^(\d+)$/ && $1 == 0)) ? 10000000 : 0;
    printd("Ys: $Ys (0 == northern hemisphere)\n");

    my $r6d = pi / 30;
    my $lg0 = $r6d * ($zone - 0.5) - pi;

    #- Mercator transverse projection
    my $n = 0.9996 * $a;
    my $e2 = $e * $e;
    my $e4 = $e2 * $e2;
    my $e6 = $e4 * $e2;
    my $e8 = $e4 * $e4;
    my @C = (1 - $e2/4 - 3*$e4/64 - 5*$e6/256 - 175*$e8/16384,
             $e2/8 + $e4/48 + 7*$e6/2048 + $e8/61440,
             $e4/768 + 3*$e6/1280 + 559*$e8/368640,
             17*$e6/30720 + 283*$e8/430080,
             4397*$e8/41287680);

    printd("north: $north Ys: $Ys n: $n c[0]: $C[0]\n");
    my $l = ($north - $Ys) / ($n * $C[0]);
    my $ls = ($east - $Xs) / ($n * $C[0]);
    printd("1- l: $l ls: $ls\n");

    my $l0 = $l;
    my $ls0 = $ls;
    foreach (1..4) {
        my $r = 2 * $_ * $l0;
        my $m = 2 * $_ * $ls0;
        my $em = exp($m);
        my $en = exp(-$m);
        my $sr = sin($r)/2 * ($em + $en);
        my $sm = cos($r)/2 * ($em - $en);
        $l -= $C[$_] * $sr;
        $ls -= $C[$_] * $sm;
    }
    printd("2- l: $l ls: $ls\n");

    my $lg = $lg0 + atan2(((exp($ls) - exp(-$ls)) / 2), cos($l));
    printd("lg: $lg\n");

    my $phi = asin(sin($l) / ((exp($ls) + exp(-$ls)) / 2));
    $l = log(tan(pi/4 + $phi/2));
    $lt = 2 * atan(exp($l)) - pi / 2;

    my $lt0;
    my $epsilon = 1e-11; #- precision in iterative schema
    do {
        $lt0 = $lt;
        my $s = $e * sin($lt);
        $lt = 2 * atan((((1 + $s) / (1 - $s)) ** ($e/2)) * exp($l)) - pi / 2;
    }
      while(abs($lt-$lt0) >= $epsilon);
    printd("lt: $lt\n");

    ($lt*180/pi, $lg*180/pi);
}


sub floor { int($_[0]) - ($_[0] < 0 ? 1 : 0) }
sub round { int($_[0] + 0.5) }
    
sub wgs84_to_utm {
    my ($lt, $lg) = @_;

    $lt = $lt*pi/180;
    $lg = $lg*pi/180;
    printd("lt: $lt lg: $lg\n");

    my $n = 0.9996 * $a;
    my $Ys = ($lt >= 0) ? 0 : 10000000;
    my $r6d = pi / 30;
    my $zone = floor(($lg + pi) / $r6d) + 1;
    printd("zone: $zone\n");

    my $lg0 = $r6d * ($zone - 0.5) - pi;
    my $e2 = $e * $e;
    my $e4 = $e2 * $e2;
    my $e6 = $e4 * $e2;
    my $e8 = $e4 * $e4;
    my @C = (1 - $e2/4 - 3*$e4/64 - 5*$e6/256 - 175*$e8/16384,
             $e2/8 - $e4/96 - 9*$e6/1024 - 901*$e8/184320,
             13*$e4/768 + 17*$e6/5120 - 311*$e8/737280,
             61*$e6/15360 + 899*$e8/430080,
             49561*$e8/41287680);

    my $s = $e * sin($lt);
    my $l = log(tan(pi/4 + $lt/2) * ((1 - $s) / (1 + $s)) ** ($e/2));
    my $phi = asin(sin($lg - $lg0) / ((exp($l) + exp(-$l)) / 2));
    my $ls = log(tan(pi/4 + $phi/2));
    my $lambda = atan(((exp($l) - exp(-$l)) / 2) / cos($lg - $lg0));
    printd("e: $e s: $s l: $l phi: $phi ls: $ls lambda: $lambda\n");

    my $north = $C[0] * $lambda;
    my $east = $C[0] * $ls;
    printd("1- north: $north east: $east\n");
    foreach (1..4) {
        my $r = 2 * $_ * $lambda;
        my $m = 2 * $_ * $ls;
        my $em = exp($m);
        my $en = exp(-$m);
        my $sr = sin($r)/2 * ($em + $en);
        my $sm = cos($r)/2 * ($em - $en);
        $north += $C[$_] * $sr;
        $east += $C[$_] * $sm;
    }
    printd("2- north: $north east: $east\n");
    $east *= $n;
    $east += $Xs;
    $north *= $n;
    $north += $Ys;
    printd("3- north: $north east: $east\n");

    ($zone, $Ys == 0, round($east), round($north));
}


sub basename { local $_ = shift; s|/*\s*$||; s|.*/||; $_ }

sub usage {
    die "Usage: ", basename($0), " [input_mode] [position values...]
  input_mode                 UTM or WGS84
  position values            values for the chosen input_mode

  Examples:
  ", basename($0), " UTM 15 N 343898 4302285
  ", basename($0), " WGS 38.855555 -94.799019

";
    
    exit -1;
}


if (lc($ARGV[0]) =~ /-d/) {
    $debug = 1;
    shift @ARGV;
}

if (lc($ARGV[0]) =~ /utm/) {
    my (undef, $zone, $isnorth, $x, $y) = @ARGV;
    my ($lat, $long) = utm_to_wgs84($zone, $isnorth, $x, $y);
    print "UTM position [$zone $isnorth $x $y] is WGS84 [$lat $long]\n";
} elsif (lc($ARGV[0]) =~ /wgs/) {
    my (undef, $lat, $long) = @ARGV;
    my ($zone, $isnorth, $x, $y) = wgs84_to_utm($lat, $long);
    print "WGS84 position [$lat $long] is UTM [$zone " . ($isnorth ? 'N' : 'S'). " $x $y]\n";
} else {
    usage();
}



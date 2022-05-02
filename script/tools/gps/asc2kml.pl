#!/usr/bin/perl

open(FIC,$ARGV[0])||die "$! not found";

print "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<kml xmlns=\"http://earth.google.com/kml/2.1\">\n  <Document>\n    <name>Arts roman et gothique en Europe</name>\n";

while(<FIC>) {
		
	next if (/^#/);
	($lat,$lon,$text)=split(/,/,$_);
	$text=~s/"//g;chomp($text);chomp($lon);chomp($lat);
	print "<Placemark>\n    <name>$text</name>\n    <Point>\n      <coordinates>$lat,$lon</coordinates>\n    </Point>\n</Placemark>\n";

}
close(FIC);

print "</Document>\n</kml>\n";

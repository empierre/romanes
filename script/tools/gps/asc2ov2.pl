#!/usr/bin/perl
use POSIX qw(ceil floor);

#Chaque POI débute par un Type codé sur 1 Octet
#POI Simple (ceux qui nous intéressent le plus souvent)
#- 1 octet de type: à 0x02
#- 4 octets pour la Taille occupée par le poi dans le fichier
#- 4 octets pour la Longitude
#- 4 octets pour la Latitude
#- n Octets en ASCII pour la description du poi (son nom) en chaine ASCI terminée par un octet nul.
#Les Coordonnées Longitudes et Latitudes sont des int exprimées en Degrés décimaux multipliés par 100 000.

open(FIC,$ARGV[0])||die "$! not found";
while(<FIC>) {
		
	next if (/^#/);
	($lat,$lon,$text)=split(/,/,$_);
	$text=~s/"//g;chomp($text);chomp($lon);chomp($lat);
	if (length(($text))<5) {next;}

#	$TT = "\x02".pack("V",length($text)+14).pack("V",ceil($lon*100000)).pack("V",ceil($lat*100000)).$text.chr(0x00); print $TT;

	#Header
	$data = "\x01";
	#$data="\x82\x81\x03\x00\xC7\x28\x0C\x00\xA7\xED\x4D\x00\x55\x39\xF8";
	#$data.= "\xFF\x89\xA8\x40\x00\x01\xB1\x6E";

	$data .= "\x02";
	$data .= pack("V", length($text + 14));
	$data .= pack("V", ceil($lon*100000));
    $data .= pack("V", ceil($lat*100000));
    $data .= $text."\x00";
	print $data;

 

}
close(FIC);


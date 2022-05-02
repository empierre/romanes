#!/usr/bin/perl

open(FIC,$ARGV[0]);
while(<FIC>){

	chomp;
	my ($lieu,$style,$void,$type,$nom,$rank,$departement,$source,$lang,$presentation,$url)=split(/;/);
	my $out="$lieu $nom $style $type $departement $presentation $source $url $lang<br><hr>\n";
	$out=~s/\x82/\&eacute;/g;
	$out=~s/\x8a/\&egrave;/g;
	$out=~s/\x0d//g;
	$out=~s/\"//g;
	print $out;
	
};
close(FIC);

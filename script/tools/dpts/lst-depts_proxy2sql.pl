#!/usr/bin/perl

open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($id,$titre,$lst)=split(/;/);

    next if (! $lst);
	
			my $out="INSERT INTO region_proxy (id,list) VALUES (\'$id\',\'$lst\');\n";
			$out=~s/\x82/\&eacute;/g;
			$out=~s/\x8a/\&egrave;/g;
			$out=~s/\x0d//g;
			$out=~s/"//g;
			print $out;

};
close(FIC);

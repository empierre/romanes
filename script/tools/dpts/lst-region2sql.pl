#!/usr/bin/perl

open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($a,$departement_id,$departement_name,$id,$region_name)=split(/;/);

    next if (! $region_name);
	
		    $region_name=~s/'/\\'/g;

			my $out="INSERT INTO region (id,title,departement_id,country) VALUES (\'$id\',\'$region_name\',$departement_id,33);\n";
			$out=~s/\x82/\&eacute;/g;
			$out=~s/\x8a/\&egrave;/g;
			$out=~s/\x0d//g;
			$out=~s/"//g;
			print $out;

};
close(FIC);

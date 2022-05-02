#!/usr/bin/perl

open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($id,$region_name)=split(/;/);

    next if (! $region_name);
	
		    $region_name=~s/'/\\'/g;

			my $out="INSERT INTO classification (id,name) VALUES (\'1$id\',\'$region_name\');\n";
			$out=~s/\x82/\&eacute;/g;
			$out=~s/\x8a/\&egrave;/g;
			$out=~s/\x0d//g;
			$out=~s/"//g;
			print $out;

};
close(FIC);

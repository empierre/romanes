#!/usr/bin/perl

open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($id,$titre,$lst)=split(/;/);

    next if (! $titre);
	
    my @list_depts=split(/,/,$lst);

		    $titre=~s/'/\\'/g;

			my $out="INSERT INTO departement (id,title,country) VALUES ($id,\'$titre\',33);\n";
			$out=~s/\x82/\&eacute;/g;
			$out=~s/\x8a/\&egrave;/g;
			$out=~s/\x0d//g;
			$out=~s/"//g;
			print $out;

	foreach $dept (@list_depts) {

			my $out="INSERT INTO region_departement (id,dept) VALUES ($id,\'$dept\');\n";

			$out=~s/\x82/\&eacute;/g;
			$out=~s/\x8a/\&egrave;/g;
			$out=~s/\x0d//g;
			$out=~s/"//g;
			print $out;
	}
			
};
close(FIC);

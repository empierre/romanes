#!/usr/bin/perl

open(FIC,$ARGV[0]);
while(<FIC>) {

	chomp;
	my ($c_id,$book,$c_name)=split(/;/);

    #next if (! $c_id);

	chomp($c_name);
	$c_name=~s/\'/\\\'/g;

	my $out="INSERT INTO classification (id,name) VALUES ($c_id,'$c_name');\n";

    print $out;
	
};
close(FIC);

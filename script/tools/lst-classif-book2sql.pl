#!/usr/bin/perl

use DBI();

open(FIC,$ARGV[0]);
while(<FIC>){

	chomp;
	my ($book_id,$book_name,$collection_name,$class_lst)=split(/;/);
	my (@classif)=split(/-/,$class_lst);


    next if (length($class_lst)<2);


	foreach $classification_id (@classif) {
		my $out="INSERT INTO cross_classification_book (classification_id,book_id) VALUES ($classification_id,$book_id);\n";
			print "$out";
	}

	print $out;
	
};
close(FIC);

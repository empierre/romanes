#!/usr/bin/perl
use Image::Info qw(image_info);

while(<*.tif>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="$myfile";
		$myresultfile=~s/\ /_/g;
		$myresultfile=~s/\.tif/\.jpg/g;
		$myfile=~s/\ /\\ /g;
		print "Image:Working on $myfile\n";

		`convert $myfile $myresultfile`;

}

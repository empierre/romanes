#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 470;
my $height= 300;

my @filename;

`mkdir jpg`;
while(<*.tif>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="$myfile";
		$myresultfile=~s/\ /_/g;
		$myresultfile=~s/\.tif/\.jpg/g;
		$myfile=~s/\ /\\ /g;
		print "Image:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh $myfile jpg/$myresultfile`;
		push @filename,"jpg/$myresultfile";

}

open(FIC,'>index.html');
foreach $fic (@filename) {
	print FIC "<img src=\"$fic\"> ";
}
close(FIC);


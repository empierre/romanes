#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 144;
my $height= 108;

`mkdir thumb`;
while(<web/*.jpg>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="thb-$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Thumb:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh web/$myfile thumb/$myresultfile`;

}
while(<web/*.jpg>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="thb-$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Thumb:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh web/$myfile thumb/$myresultfile`;

}



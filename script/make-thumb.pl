#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 144;
my $height= 108;

`mkdir thumb`;
open(IDX,"images.idx");
<IDX>;
<IDX>;
<IDX>;
while(<IDX>) {
    	chomp;
		next if (/^#/);
		my $myfile=$_;
		my $myresultfile="thb-$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Thumb:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh $myfile thumb/$myresultfile`;

}
close(IDX);


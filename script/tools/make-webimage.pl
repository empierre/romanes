#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 470;
my $height= 300;

`mkdir webimg`;
open(IDX,"images.idx");
<IDX>;
<IDX>;
<IDX>;
while(<IDX>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Image:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh $myfile webimg/$myresultfile`;

}
close(IDX);


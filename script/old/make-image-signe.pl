#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 1024;
my $height= 768;
my $path_to_wp="/cygdrive/f/romanes/script/old/";

my $info = image_info("$path_to_wp/romanes2-logo.jpg");
$sig_width  = $info->{width};
$sig_height = $info->{height};
my $sig_dec=$sig_width+$sig_width1+4;
my $sig_dic=$sig_height-3;

`mkdir signe`;

open(IDX,"images.idx");
<IDX>;
<IDX>;
<IDX>;
while(<IDX>) {
    	chomp;
		my $myfile="web/".$_;
		my $myresultfile="wallpaper-$myfile";
		$myresultfile=~s/\ /_/g;
		print "WPHigh:Working on $myfile\n";

		my $info = image_info($myfile);
		if (my $error = $info->{error}) {
				 die "Can't parse image info: $error\n";
		}

		my $img_width=$info->{width};
		my $img_height=$info->{height}; 

		$myfile=~s/\ /\\ /g;

		my $tempfile=$myfile;
		my $sig_dec=0;
		my $sig_dic=$img_height-$sig_height;
		# Logo
		`composite -background black  -geometry +$sig_dec+$sig_dic $path_to_wp/romanes2-logo.jpg $tempfile signe/$myresultfile`;
		if ($tempfile ne $myfile) { 
			`rm  $tempfile`;	
		};
}
close(IDX);


#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 1024;
my $height= 768;
my $path_to_wp="/root/romanes2/script/";

my $info = image_info("$path_to_wp/copyright-for-wallpaper.jpg");
my $sig_width1  = $info->{width};
my $sig_height1 = $info->{height};
#print STDERR "-$sig_width1-$sig_height1-\n";
my $info = image_info("$path_to_wp/romanes2-logo.jpg");
$sig_width2  = $info->{width};
$sig_height2 = $info->{height};
#print STDERR "-$sig_width2-$sig_height2-\n";

$sig_width  = int(($width-$sig_width1-$sig_width2-4)/2);
$sig_height = $height-$sig_height1-6;
#print STDERR "-$sig_width-$sig_height-\n";

my $size=$width."x".$height;
`composite -size $size -background black  -geometry +$sig_width+$sig_height $path_to_wp/copyright-for-wallpaper.jpg $path_to_wp/wallpaper-$width-$height-black.jpg wallpaper-$width-$height-signed-temp.jpg`;

my $sig_dec=$sig_width+$sig_width1+4;
my $sig_dic=$sig_height-3;
`composite -size $widthx$height -background black  -geometry +$sig_dec+$sig_dic $path_to_wp/romanes2-logo.jpg wallpaper-$width-$height-signed-temp.jpg wallpaper-$width-$height-signed.jpg`;

`rm wallpaper-$width-$height-signed-temp.jpg`;
`mkdir wp-$size`;

open(IDX,"images.idx");
<IDX>;
<IDX>;
<IDX>;
while(<IDX>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="wallpaper-$myfile";
		$myresultfile=~s/\ /_/g;
		print "WPHigh:Working on $myfile\n";

		my $info = image_info($myfile);
		if (my $error = $info->{error}) {
				 die "Can't parse image info: $error\n";
		}

		my $img_width=$info->{width};
		my $img_height=$info->{height}; 

		my $x=int(($width-$img_width)/2);
		my $y=int(($height-$img_height)/2);

		#print STDERR "-$x-$y-\n";
		$size=$width."x".$height;

        $myfile=~s/\ /\\ /g;

	# Scale ???
	my $tempfile="temp-".$myfile;
	if (($img_width>=$width)||($img_height>=$height)) {
		my $wh=$width."x".($height-30);
		`convert -scale $wh $myfile $tempfile`;

		# New Infos
        my $mytf=$tempfile;
		$mytf=~s/\\//g;
		my $info = image_info($mytf);
		if (my $error = $info->{error}) {
				 die "Can't parse image info: $error\n";
		}

		$img_width=$info->{width};
		$img_height=$info->{height}; 

		$x=int(($width-$img_width)/2);
		$y=int(($height-$img_height)/2);

		$size=$width."x".$height;
	} else {
		$tempfile=$myfile;
	}
	# Picture
	`composite -size $size -geometry +$x+$y $tempfile wallpaper-$width-$height-signed.jpg $myresultfile`;
	# Black bar
	my $shei=$sig_height-4;
	`composite -size $size -background black -geometry +0+$shei $path_to_wp/black-bar.jpg $myresultfile $myresultfile`;
	my $shei=$sig_height+4;
	`composite -size $size -background black -geometry +0+$shei $path_to_wp/black-bar.jpg $myresultfile $myresultfile`;
	# Copyright
	`composite -size $size -background black  -geometry +$sig_width+$sig_height $path_to_wp/copyright-for-wallpaper.jpg $myresultfile wallpaper-$width-$height-signed-temp.jpg`;
	# Logo
	`composite -size $widthx$height -background black  -geometry +$sig_dec+$sig_dic $path_to_wp/romanes2-logo.jpg wallpaper-$width-$height-signed-temp.jpg wp-$size/$myresultfile`;
	# Clean-Up
	`rm  wallpaper-$width-$height-signed-temp.jpg`;
	if ($tempfile ne $myfile) { 
		`rm  $tempfile`;	
	};
}
close(IDX);


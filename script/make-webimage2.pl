#!/usr/bin/perl
use Image::Info qw(image_info);
use Image::ExifTool qw(:Public);

my $x_size = 1024;
my $y_size = 800;

`mkdir web`;
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
		my $exif = new Image::ExifTool;
	        my $data = $exif->ImageInfo($myfile);
		my $ewh = $exif->GetValue('ImageSize');
		my ($width,$height)=($ewh=~/(\d+)x(\d+)/);
		my $wh;
		if ($height) {
		print "Image:Working on $myfile ";

		$x_scale = $x_size / $width;
	        $y_scale = $y_size / $height;
	        $scale = $x_scale;
	        if ( $y_scale < $scale ) {
	            $scale = $y_scale;
	        }
	        $new_x = int( $width * $scale + 0.5 );
	        $new_y = int( $height * $scale + 0.5 );
		$wh=$new_x."x".$new_y;
		print "$width x $height ->  $new_x x  $new_y  ==> $wh\n";

		#`convert -scale $wh -unsharp 0x0.75+0.75+0.008 $myfile web/$myresultfile`;
		`convert -scale $wh -unsharp 1.5x1+0.7+0.02 $myfile web/$myresultfile`;
		}

}
close(IDX);


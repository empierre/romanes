#!/usr/bin/perl
use Image::Info qw(image_info);

my $base=@ARGV[0]||'.';

`mkdir $base/optim`;
open(IDX,"$base/images.idx");
<IDX>;
<IDX>;
<IDX>;
while(<IDX>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="$myfile";
        $myfile=~s/\ /\\ /g;
        $myresultfile=~s/\ /\\ /g;
		print "Optim:Working on $myfile\n";

		#`convert -interlace NONE -sharpen 50 -border 2x2 -comment '(C)Emmanuel PIERRE All Rights Reserved.' $myfile optim/$myresultfile`;
		`convert -interlace NONE -sharpen 50 -comment '(C)Emmanuel PIERRE All Rights Reserved.' $base/$myfile $base/optim/$myresultfile`;

		

}
close(IDX);


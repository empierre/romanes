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
		my $myfile="web/".$_;
		my $myresultfile="thb-$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Thumb:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh web/$myfile thumb/$myresultfile`;

}

`make-image-signe.pl`;

my %web_host_album=(
	"9" => "/mnt/data/prod/romanes.org/",
	"8" => "/mnt/data/prod/www.romanes.com/",
	"1" => "/mnt/data/prod/freeromanes/",
	"2" => "/mnt/data/prod/freeromanes2/",
	"3" => "/mnt/data/prod/freeromanes3/",
	"4" => "/mnt/data/prod/freeromanes4/",
    "5" => "/mnt/data/prod/freeromanes5/",
    "6" => "/mnt/data/prod/freeromanes6/",
    "7" => "/mnt/data/prod/freeromanes7/"
);

# Opens Album.idx
if ($debug) {print STDERR "Opening album.idx\n";}
open(ALB,"$out_dir/album.idx")|| die "no album $out_dir/album.idx!\n";
my ($onsite,$onsite_thb,$onsite_img);
while (<ALB>) {
    chomp;
	if (/^onsite_img/) {
        ($tmp,$onsite_img)=split(/:/,$_);
        if (!$onsite_img) {$onsite_img=1;} }
    if (/^onsite_thb/) {
        ($tmp,$onsite_thb)=split(/:/,$_);
        if (!$onsite_thb) {$onsite_thb=1;} }
}
close(ALB);

`mv thumb/* $web_host_album{$onsite_thb}`;
`mv signe/* $web_host_album{$onsite_img}`;
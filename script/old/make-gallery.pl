#!/usr/bin/perl
use Image::Info qw(image_info);

my $width = 240;
my $height= 240;

my @filename;

my $result;my $cnt;
`mkdir jpg`;
while(<*.JPG>) {
	my $myresultfile=$_;
	$myresultfile=~s/\.JPG$/\.jpg/;
	`mv $_ $myresultfile`;
}
$result.="<table>\n\n\n";
while(<*.jpg>) {
    	chomp;
		my $myfile=$_;
		my $myresultfile="$myfile";
		$myresultfile=~s/\ /_/g;
		$myfile=~s/\ /\\ /g;
		print "Image:Working on $myfile\n";

		my $wh=$width."x".$height;
		`convert -scale $wh $myfile jpg/$myresultfile`;

		$result.="<td align=\"center\" valign=\"bottom\"><font face=\"Arial\" size=\"-2\"><a href=\"$myfile\"><img src=\"jpg\/$myresultfile\" alt=\"$myfile\"><br>$myfile</a></font></td>\n";
	
		$cnt++;	
		if ($cnt>=3) {
			$result.="</tr>\n\n<tr>\n";
			$cnt=0;
		}


}
$result.="</table>\n\n\n";

open(FIC,'>index.html');
print FIC $result;
close(FIC);


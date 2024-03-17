#!/usr/bin/perl 

# author : sergey s prozhogin (ccpro@rrelaxo.org.ru)
# script renames file by EXIF date
# for information start perl rename.pl
#
# v 1.4 May-20-2006
#

use strict;
use Image::ExifTool qw(:Public);
use Date::Parse;
use Data::Dumper;
use POSIX qw(strftime);

#my @list = `ls -1 Copie*JPG IMG*JPG *.jpg *.JPG *jpeg *JPEG`;
my @list = glob("Copie*JPG IMG*JPG *.jpg *.JPG *jpeg *JPEG");
print @list;
my $exif = new Image::ExifTool;

for my $fname (@list)
{
	chomp $fname;

	my $data = $exif->ImageInfo($fname);

	if ($data)
	{
#print $data->{image}->{'Image Created'}." - ". $data->{other}->{'Image Generated'}."\n";
		my $timestamp = $exif->GetValue('CreateDate') || $exif->GetValue('FileModifyDate');
		my $maker = $exif->GetValue('Make');
		my $model = $exif->GetValue('Model');
		my $mkr;my $suffix;
		if ($model =~/A80/) { $mkr="a80"; } 
		elsif ($model =~/TZ1/) { $mkr="tz1"; } 
		elsif ($model =~/A345/) { $mkr="a345"; } 
		elsif ($model =~/F100fd/) { $mkr="f100"; } 
		elsif ($model =~/IXUS 980/) { $mkr="i980"; } 
		elsif ($model =~/DSLR-A350/) { $mkr="a350"; } 
		elsif ($model =~/Canon EOS 5D/) { $mkr="E5D"; } 
		elsif ($model =~/Canon EOS 6D/) { $mkr="E6D"; } 
		elsif ($model =~/Canon EOS 550D/) { $mkr="E550"; } 
		elsif ($model =~/Nexus 6P/) { $mkr="N6P"; } 
		elsif ($model =~/Pixel 3 XL/) { $mkr="P3XL"; } 
		elsif ($model =~/Pixel 6 Pro/) { $mkr="P6PR"; } 
		else { $mkr="GEN"; }
		#print $mkr."\n";
		if ($fname =~/_pt/) {
			$suffix="_pt";
		}
		my ($seq)=($fname=~ /(\d{4}).jpg/);
		if ($seq) {$seq="_".$seq;} else {
			($seq)=($fname=~ /\s(\d+)/);
			if ($seq) {$seq="_".&pad_number($seq);}
		}

print "SEQ USED: $seq.\n";
		my $time =$timestamp;
#print $time."\n";
		#my $time = str2time($timestamp);
		($timestamp)=($time=~/^(\S+)\s.*/);
		$timestamp=~s/:/-/g;

		#$timestamp = strftime "%F", $time;

print "TIM USED: $seq.\n";
		my $count = 0;my $cntr;
		if (! $seq) {$cntr="_".&pad_number($count);}
		while (-f $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg") {
			$count++;
			$cntr="_".&pad_number($count);
		}
		#if ((!$seq)&&($count==0)) {$cntr="_0000";}
		if ($count==0) {$cntr="_0000";}
		if (! -e $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg") {
			rename $fname, $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg";
		} else {
			warn("duplicate file");
		}
		#print $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg\n";
	}
}

exit;

sub pad_number {
	my ($nr) = @_;
	my $res;
	if ($nr<10) { $res="000".$nr; }
	elsif ($nr<100) { $res="00".$nr; }
	elsif ($nr<1000) { $res="0".$nr; }
	return($res);	
}

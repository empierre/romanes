#!/usr/bin/perl 

# author : sergey s prozhogin (ccpro@rrelaxo.org.ru)
# script renames file by EXIF date
# for information start perl rename.pl
#
# v 1.4 May-20-2006
#

use strict;
use Image::EXIF;
use Date::Parse;
use Data::Dumper;
use POSIX qw(strftime);

my @list = `ls -1 Copie*JPG IMG*JPG *jpg *.JPG *jpeg *JPEG`;

my $exif = new Image::EXIF;

for my $fname (@list)
{
	chomp $fname;

	$exif->file_name($fname);
	my $data = $exif->get_all_info();

	if ($data)
	{
#print $data->{image}->{'Image Created'}." - ". $data->{other}->{'Image Generated'}."\n";
		my $timestamp = $data->{other}->{'Image Generated'} || $data->{image}->{'Image Created'} ; 
		my $maker = $data->{camera}->{'Equipment Make'} || $data->{other}->{'Equipment Make'};
		my $model = $data->{camera}->{'Camera Model'} || $data->{other}->{'Camera Model'};
		my $mkr;my $suffix;
		if ($model =~/A80/) { $mkr="a80"; } 
		elsif ($model =~/TZ1/) { $mkr="tz1"; } 
		elsif ($model =~/A345/) { $mkr="a345"; } 
		elsif ($model =~/F100fd/) { $mkr="f100"; } 
		elsif ($model =~/DSLR-A350/) { $mkr="a350"; } 
		elsif ($model =~/Canon EOS 5D/) { $mkr="E5D"; } 
		elsif ($model =~/Canon EOS 550D/) { $mkr="E550"; } 
		else { $mkr="gen";next; }
		#print $mkr."\n";
		if ($fname =~/_pt/) {
			$suffix="_pt";
		}
		my ($seq)=($fname=~ /(\d{4})/);
		if ($seq) {$seq="_".$seq;} else {
			($seq)=($fname=~ /\s(\d+)/);
			if ($seq) {$seq="_".&pad_number($seq);}
		}

print $seq."\n";
		my $time =$timestamp;
#print $time."\n";
		#my $time = str2time($timestamp);
		($timestamp)=($time=~/^(\S+)\s.*/);
		$timestamp=~s/:/-/g;

		#$timestamp = strftime "%F", $time;

		my $count = 0;my $cntr;
		if (! $seq) {$cntr="_".&pad_number($count);}
		while (-f $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg") {
			$count++;
			$cntr="_".&pad_number($count);
		}
		if ((!$seq)&&($count==0)) {$cntr="_0000";}
		rename $fname, $mkr."_".$timestamp.$seq.$cntr.$suffix.".jpg";
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

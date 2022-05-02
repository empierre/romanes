#!/usr/bin/perl
#
# Insertion de collecte Edifices_Religieux_Fr.asc
#

open(FIC,@ARGV[0]) || die "$! not found\n";
while(<FIC>) {
next if (/^;/);
next if (/^\r/);

next if (/protestant/);
next if (/pagode/);
next if (/temple/);
next if (/synagogue/);
next if (/mosquée/);
next if (/foyer/);
next if (/ossuaire/);

my $star=0;
if(/\*/) {$star=1;$_=~s/\*//;}

$_=~s/\r\n//;

my ($lon,$lat,$texte)=split(/,/,$_,3);
chomp($texte);
$lon=~s/ //;
$lat=~s/ //;
#print "$lon $lat -$texte-\n";

my ($head,$dept,$ext)=($texte=~/"\[(.+)\]\s+(.{2})\s?\(?(.+)\)?"/);

#my ($type,$nv,$dept,$town,$ext)=($text=~/^"\[(.+)\s?([nv]*)\]\s(\d{2})\s(.+)\s?\(?(.*)\)?"$/);

my ($type,$nv)=split(/ /,$head);
my ($town,$name)=($ext=~/([^(]*)\s?\(?([^\)]*)\)?/);
$town=~s/ $//;

if ($nv) {$nv=1} else {$nv=0;};

if ($dept eq 'CH') {$country=756;$dept=0;} else {$country=250;};

$town=~s/\'/\\\'/g;
$name=~s/\'/\\\'/g;

print "INSERT INTO COLLECTE_GPS_EDIF VALUES(null,$nv,'$lon','$lat',$country,$dept,'$type','$town','$name','',null,0,1,$star);\n";


}
close(FIC);

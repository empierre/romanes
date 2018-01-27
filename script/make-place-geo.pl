#!/usr/bin/perl
# generate per region POI
#
# template: romanes_map_tmpl.xml
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;

#version
my $version_dev="3.0.0";

#use strict;
my $local_tmpl="/mnt/data/web/prod/r2/templates/";

my %web_host_album=(
        "1"=>"http://www.romanes.com/",
        "2"=>"http://www.romanes.com/",
        "3"=>"http://www.romanes.com/",
        "4"=>"http://www.romanes.com/",
        "5"=>"http://www.romanes.com/",
        "6"=>"http://www.romanes.com/",
        "7"=>"http://www.romanes.com/",
        "8"=>"http://www.romanes.com/",
        "9"=>"http://www.romanes.com/",
        "10"=>"http://www.romanes.com/",
        "11"=>"http://www.romanes.com/",
        "12"=>"http://www.romanes.com/"
);
my $reference_onsite=8;

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");
&sql_update($dbh2,"SET NAMES utf8");


open(FIC,$local_tmpl."romanes_map_tmpl.xml");
while(<FIC>) {
  print $_;
}
close(FIC);


my ($album_id, $album_title, $place_lat, $place_lng, $album_url, $place_town, $onsite);
$sql = "select distinct album.id, album.title, place.lat,place.lng,album.url,place.town,album.onsite from album,place,album_place where album.id=album_place.album_id and place.id=album_place.place_id order by album.id";
$sth = $dbh->prepare($sql);
$sth->execute();

$sth->bind_columns(\$album_id, \$album_title, \$place_lat, \$place_lng, \$album_url, \$place_town, \$onsite);
while ($sth->fetch()) {

	print "<site>\n";
	print "\t<id>$album_id</id>\n";
	print "\t<name>$album_title</name>\n";
	print "\t<type>branch</type>\n";
	print "\t<lat>$place_lat</lat>\n";
	print "\t<lng>$place_lng</lng>\n";
	print "\t<url>".$web_host_album{$onsite}."$album_url</url>\n";
	print "\t<addr_city>$place_town</addr_city>\n";

	my $thb_fic=&sql_get($dbh2,"select photo.thumb_file from photo,album_photo where album_photo.album_id=$album_id and photo.id=album_photo.photo_id and album_photo.display_order=1");

	if ($thb_fic) {
		print "\t<thumb>http://www.romanes.com/media/thumb/$thb_fic</thumb>\n";
	}	

    print "</site>\n";
	my $album_id='';

}

print "</romanes_worldwide>\n";

$sth->finish();
exit;


sub get_classification {
	my ($book_id)=@_;
	my $res;
	$sql = "select distinct cross_classification_book.classification_id from cross_classification_book where cross_classification_book.book_id=$book_id";
	my $sth = $dbh2->prepare($sql);
    $sth->execute();
    my ($id);
    $sth->bind_columns(\$id);
    while ($sth->fetch()) {
		if (!$res) {$res=$id}
		else {$res.=",".$id;}
	}
    $sth->finish();

	return $res;

}

sub generate_sernum {
    my ($original_file,$author_id,$creation_date,$place_id,$id) = @_;

    my $sql="SELECT postcode FROM place WHERE id=$place_id";
    my $postcode=&sql_get($dbh,$sql);

    my $sql="SELECT country FROM place WHERE id=$place_id";
    my $country=&sql_get($dbh,$sql);

    # S/R procedure
    ($seq1)=($original_file=~/.*([0-9]+)\.jpg$/);
    #AAAOO-NNN-DDDD-XXXX
    my $lg=length($seq1);
    for($i=$lg;$i<4;$i++) {
        $seq1="0".$seq1;
    }
    my $sr="$country-$postcode-$seq1-$id";
    return($sr);
}

sub sql_get {
    my ($dbh,$sql) = @_;

    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my $res;my $r;
    $sth->bind_columns(\$res);

    while ($sth->fetch()) {
        $r=$res;
    }
    $sth->finish();

    return($r);
}

sub sql_update {
		my ($dbh,$sql) = @_;
			my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
			return($rc);
		}


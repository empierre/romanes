#!/usr/bin/perl
# Make a list of site per regions in KML2
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
#use strict;

#version
my $version_dev="3.0.0";

my $dbh = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";
my $dbh2 = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";

&sql_update($dbh,"SET NAMES utf8");
&sql_update($dbh2,"SET NAMES utf8");


my $local_tmpl='/mnt/data/prod/r2/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";
my $debug=0;

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

#Generate site list
#
print STDERR "Generating Google Earth KML file";
open(FIC,$local_tmpl."romanes_map_tmpl.kml")||die "$!";
while(<FIC>) {
  print $_;
}
close(FIC);

#Generate Countries
my %country_list;
my $sql="select id,name from country order by name";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@f_region,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
while ($sth->fetch()) {
	$country_list{$pid}=$ptitle;
}

foreach $country (keys %country_list) {

		#Generate per region section
		#
		my $sql="select id,title from region_state where country=$country order by title";
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		if ($sth->rows>1) {
			print "<Folder>\n<name>".$country_list{$country}."</name>\n";
			my ($pid,@t_region,$ptitle);
			$sth->bind_columns(\$pid,\$ptitle);
			while ($sth->fetch()) {
					my @l_region=($pid);
					#push @l_region,$pid;
					$ptitle=~s/\s/_/g;
					$ptitle=~s/\'/_/g;
					$ptitle=~tr/???????/eeeaaoo/;
					&generate_region($country,$pid,$ptitle);
			}
		print "</Folder>\n";
		} elsif ($sth->rows==1) {
			print "<Folder>\n<name>".$country_list{$country}."</name>\n";
			&generate_region($country,0,0);
			print "</Folder>\n";
		}
}

print "</Document>\n";
print "</kml>\n";


$dbh->disconnect;
$dbh2->disconnect;
print STDERR "Done\n";
exit;


sub generate_region {
		my $country_id=shift(@_);
		my $region_id=shift(@_);
		my $region_name=shift(@_);
		my @t_region;

		my (%l_department);
		my $sql;
		if ($region_id) {
			$sql="select distinct album.id from album,album_place,place where album.id=album_place.album_id  and album_place.place_id=place.id and place.region_id=$region_id and place.country=$country_id";
		} else {
			$sql="select distinct album.id from album,album_place,place where album.id=album_place.album_id  and album_place.place_id=place.id and place.country=$country_id";
		}
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		if ($sth->rows>0) {
			if ($region_id) {print "<Folder>\n<name>".$region_name."</name>\n";}
			my ($pid,@t_department);
			$sth->bind_columns(\$pid);
			while ($sth->fetch()) {
				&get_album_from_id($pid);
			}
			if ($region_id) {print "</Folder>\n";}
		}
}


sub get_album_from_id($) {
	my $album_id=shift(@_);

	my $sql="select photo.id,photo.thumb_file,album.title,album.url,place.town,album.epoch_str,album.epoch_style,place.lng,place.lat,album.onsite from photo,place,album,album_photo where album.id=album_photo.album_id and album_photo.photo_id=photo.id and photo.place_id=place.id and album.id=$album_id and album_photo.publish=1 order by photo.id limit 1";
	#print STDERR $sql."\n";
	my $sth2 = $dbh2->prepare($sql);
	$sth2->execute();
	my ($pid,$tf,$nm,$album_url,$place_name,$epoch_str,$epoch_style,$town_name,$place_lng,$place_lat,$onsite);
	$sth2->bind_columns(\$pid,\$tf,\$nm,\$album_url,\$town_name,\$epoch_str,\$epoch_style,\$place_lng,\$place_lat,\$onsite);
	while ($sth2->fetch()) {
			print "<Placemark>\n";
			print "\t<name>$nm</name>\n";
			print "\t<description>\n";
			print "\t<![CDATA[";
			print "$nm, $town_name";

	my $thb_fic=&sql_get($dbh2,"select photo.thumb_file from photo,album_photo where album_photo.album_id=$album_id and photo.id=album_photo.photo_id and album_photo.display_order=1");

    if ($thb_fic) {
        print "<img align=\"right\" src=\"http://www.romanes.com/media/thumb/$thb_fic\"/>";
    }

    print "<br/><br/>Voir l'album: <a href=\"$web_host_album{$onsite}$album_url\">$nm</a>";


			print "]]>\n";
			print "\t</description>\n";
			print "\t<styleUrl>#default</styleUrl>\n";
			print "\t<Point>\n";
			print "\t\t<coordinates>$place_lng,$place_lat</coordinates>\n";
			print "\t</Point>\n";
			print "\t</Placemark>\n";


		
	}
}


sub get_region_by_id($){
	my ($id)=shift;
	my $sql="select title from region_state where id=$id";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid);
	$sth->bind_columns(\$pid);
	while ($sth->fetch()) {
		$id=$pid;
	}

	return($id);
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

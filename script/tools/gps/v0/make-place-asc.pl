#!/usr/bin/perl
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
#use strict;

#Updated for templates/pages/regions

# Make a list of site per regions

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";
my $debug=0;

#Generate site list
#
print STDERR "Generating POI file";
print "# Arts roman et gothique en Europe\r\n";

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
			my ($pid,@t_region,$ptitle);
			$sth->bind_columns(\$pid,\$ptitle);
			while ($sth->fetch()) {
					my @l_region=($pid);
					#push @l_region,$pid;
					$ptitle=~s/\s/_/g;
					$ptitle=~s/\'/_/g;
					$ptitle=~tr/éèêàâôö/eeeaaoo/;
					&generate_region($country,$pid,$ptitle,$country_list{$country});
			}
		} elsif ($sth->rows==1) {
			&generate_region($country,0,0,$country_list{$country});
		}
}


$dbh->disconnect;
$dbh2->disconnect;
print STDERR " done\n";
exit;


sub generate_region {
		my $country_id=shift(@_);
		my $region_id=shift(@_);
		my $region_name=shift(@_);
		my $country_name=shift(@_);
		my @t_region;

		my (%l_department);
		my $sql;
		if ($region_id) {
			$sql="select DISTINCT album.id,album.title,place.town,place.department_id,place.lat,place.lng,album.epoch_style from album,album_place,place where album.id=album_place.album_id  and album_place.place_id=place.id and place.region_id=$region_id and place.country=$country_id";
		#print $sql."\n";
		} else {
			$sql="select DISTINCT album.id,album.title,place.town,place.department_id,place.lat,place.lng,album.epoch_style  from album,album_place,place where album.id=album_place.album_id  and album_place.place_id=place.id and place.country=$country_id";
		#print $sql."\n";
		}
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		if ($sth->rows>0) {
			my ($pid,@t_department,$name,$town,$department_id,$lat,$lng,$epoch_style);
			$sth->bind_columns(\$pid,\$name,\$town,\$department_id,\$lat,\$lng,\$epoch_style);
			while ($sth->fetch()) {
				if ($country_name ne "France") {
					if ($country_name eq "Suisse") { $country_name="CH";}
					print "$lng, $lat, \"[$epoch_style] $country_name $town ($name)\"\r\n";
				} else {
					print "$lng, $lat, \"[$epoch_style] $department_id $town ($name)\"\r\n";
				}
			}
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


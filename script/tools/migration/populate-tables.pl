#!/usr/bin/perl
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;

# Gnerate a plan list per region

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

my $dbh2 = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";


my $sql="select id from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@t_region);
$sth->bind_columns(\$pid);
while ($sth->fetch()) {
	push @t_region,$pid;
}

my (%l_department);
foreach my $dpt (@t_region) {
	my $sql="select id from region where departement_id=$dpt";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid,@t_department);
	$sth->bind_columns(\$pid);
	while ($sth->fetch()) {
		$l_department{$dpt}.="$pid,";
	}
}


my @tab_site_loop;
my $odd_even=0;my %tab={};
foreach my $k (@t_region) {
	my @l=split(/,/,$l_department{$k});
	my $loop;my $cnt;my @loop1;my $loop0;my @loop0;my $reg_cnt;

	foreach my $v (@l) {

		my $sql="select album.id,album_place.place_id,map.map_img_low,album.title,album.url,place.id,map.id from map,album,place,album_place where map.album_id=album_place.album_id and album_place.album_id=album.id and album_place.place_id=place.id and place.postcode rlike '^$v' order by place.id";
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str);
		my %mem_dep;
		$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$album_url,\$town_name,\$epoch_str);
		while ($sth->fetch()) {

			print "UPDATE map SET place_id=$town_name where map.id=$epoch_str;\n";
			print "INSERT INTO map_album VALUES ($pid,$epoch_str);\n";
	
		}
	}
}
$dbh->disconnect;
print STDERR "ok\n";
exit;


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

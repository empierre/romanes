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

print "; This Ascii PoiFile was generated on 29/07/2007 by PoiEdit, ©2002-2007 by Dnote Software (http://www.dnote.nl). All rights reserved.\r\n";


$sql="select id,nv,lon,lat,country,departement,epoch_style,town,name,is_starred from COLLECTE_GPS_EDIF where is_collecte_roman=1";

my $sth = $dbh->prepare($sql);
$sth->execute();
if ($sth->rows>0) {
		my ($id,$nv,$lon,$lat,$country,$departement,$type,$town,$name,$is_starred);
		$sth->bind_columns(\$id,\$nv,\$lon,\$lat,\$country,\$departement,\$type,\$town,\$name,\$is_starred);
		while ($sth->fetch()) {
			next if ($type eq 'Civil');
			if ($is_starred) {$is_starred='*'} else {$is_starred=''}
			if ($nv) {$nv=' nv'} else {$nv='';}
			if ($country != 250) {
				if ($country==756) {$country_name="CH";}
				print "$lon, $lat, \"[$type$nv] $country_name $town ($name)$is_starred\"\r\n";
			} else {
				print "$lon, $lat, \"[$type$nv] $departement $town ($name)$is_starred\"\r\n";
			}
		}
	}
$dbh->disconnect;
$dbh2->disconnect;
print STDERR "Done\n";
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


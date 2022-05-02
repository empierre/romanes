#!/usr/bin/perl
#
# de la liste des POI de collecte crée les insert pour updater Romanes
# mysql -u root ROMANES3 -e "select id from COLLECTE_GPS_EDIF where is_collecte_edifices=1 and is_collecte_roman=1;" > d.txt
#

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

	my @a=(23001,23003,23019,23022,23026,23029,23031,23063,23069,23085,23087,23089,23094,23095,23098,23100,23120,23127,23129,23133,23141,23144,23150,23153,23154,23193,23687,23699,23700,23702,23927,23957,24048,24079,24080,24137,24246,24248,24249,24268,24275,24659,25010,25011,25582,25680,25688,25691,25899,25914,25919,26024,26215,26395,26403,26423,26475,26483,26514,26673,26702,26707,26712,26802,26885,26886,26888,27309);

	foreach $in (@a) {
		#print $in."\n";
		&get_infos($in);
	}

$sth1->finish();
#$sth2->finish();
#$sth->finish();
exit;


sub get_infos {
	$id=@_[0];

	$sql = "select lat,lon,album_id from COLLECTE_GPS_EDIF where id=$id;";
	$sth1 = $dbh1->prepare($sql);
	$sth1->execute();

	my ($lat,$lon,$album_id);
	$sth1->bind_columns(\$lat,\$lon,\$album_id);

	while ($sth1->fetch()) {


		my $place_id=&sql_get($dbh,"select place_id from album_place where album_id=$album_id");

		print "UPDATE place SET lng=$lon,lat=$lat WHERE id=$place_id;\n";
	}
}



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


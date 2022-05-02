#!/usr/bin/perl
#
# de la liste des albums pas en collecte crée les insert pour compléter l'ensemble
#

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

	my @a=(1,2,5,6,7,11,15,16,17,18,19,20,21,22,26,28,29,31,32,33,34,41,42,43,44,45,46,48,49,50,52,54,56,57,58,60,62,65,66,67,70,73,74,75,76,85,86,87,88,90,92,93,94,95,96,97,99,104,106,108,109,112,114,115,116,117,119,120,121,122,123,127,130,131,133,137,139,141,142,143,145,146,151,152,153,154,157,158,159,160,161,162,163,164,165,166,167,171,173,174,177,178,179,181,182,184,185,186,187,188,189,190,191,192,194,195,197,198,199,200,201,202,205,207,208,209,210,211,212,213,214,216,217,219,220,221,225,226,227,228,229,230,231,232,234,235,236,237,238,240,241,242,243,244);

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

	$sql = "select distinct album.id,album.epoch_style,album.title,place.town,place.name,place.department_id,place.country,place.lat,place.lng from album,place,album_place where album_place.album_id=album.id and album_place.album_id = $id and album_place.place_id=place.id;";
	$sth1 = $dbh1->prepare($sql);
	$sth1->execute();

	my ($album_id,$epoch_style,$title,$town,$name,$department_id,$country,$lat,$lng);
	$sth1->bind_columns(\$album_id,\$epoch_style,\$title,\$town,\$name,\$department_id,\$country,\$lat,\$lng);

	while ($sth1->fetch()) {

		$type=$epoch_style;

		$town=~s/\'/\\\'/g;
		$name=~s/\'/\\\'/g;
		$type=~s/\'/\\\'/g;

		print "INSERT INTO COLLECTE_GPS_EDIF VALUES (null,1,$lng,$lat,$country,$department_id,'$type','$town','$name',null,$album_id,1,0,1);\n";
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


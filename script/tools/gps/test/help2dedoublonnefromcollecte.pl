#!/usr/bin/perl
#
# matching basique pour finition manuelle entre album/place et COLLECTE_GPS_EDIF
# 

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


$sql = "select id,name,town,department_id,country from place;";
$sth1 = $dbh1->prepare($sql);
$sth1->execute();

my ($id,$name,$town,$department_id,$country);
$sth1->bind_columns(\$id,\$name,\$town,\$department_id,\$country);

while ($sth1->fetch()) {

	$town=~s/\'/\\\'/g;

	$sql2 = "select id,name,town,departement,country from COLLECTE_GPS_EDIF where town='$town' and departement=$department_id";
	#print $sql2."\n";
	$sth2 = $dbh2->prepare($sql2);
	$sth2->execute();
	my ($id2,$name2,$town2,$department_id2,$country2);
	$sth2->bind_columns(\$id2,\$name2,\$town2,\$department_id2,\$country2);
	while ($sth2->fetch()) {
		print "# $id=$id2-$name=$name2-$town=$town2-$department_id=$department_id2-$country=$country2\n";
		my $album_id=&sql_get($dbh,"select album_id from album_place where place_id=$id");
		print "UPDATE COLLECTE_GPS_EDIF SET album_id=$album_id,is_collecte_roman=1 WHERE id=$id2;\n";
	}
}
$sth2->finish();
$sth1->finish();
#$sth->finish();
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


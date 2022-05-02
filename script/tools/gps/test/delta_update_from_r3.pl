#!/usr/bin/perl
#
# de la liste des albums pas en collecte update les informations
#
# mysql -u root ROMANES3 -e "select album_id from COLLECTE_GPS_EDIF where is_collecte_edifices=1 and album_id>0;" > e.txt
#

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

	my @a=(3,40,77,140,98,110,125,222,36,196,147,193,102,103,4,101,39,68,35,183,144,118,215,138,100,72,53,38,239,129,89,3,155,51,245,233,69,61,72,105,63,101,172,175,124,183,176,180,224,218,223,55,98,132,128,204,156,150,203,100,12,27,30,126,168,170,169,148);

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

	$sql = "select distinct album.id,album.epoch_style,album.title,place.town,place.name from album,place,album_place where album_place.album_id=album.id and album_place.album_id = $id and album_place.place_id=place.id;";
	$sth1 = $dbh1->prepare($sql);
	$sth1->execute();

	my ($album_id,$epoch_style,$title,$town,$name);
	$sth1->bind_columns(\$album_id,\$epoch_style,\$title,\$town,\$name);

	while ($sth1->fetch()) {


		my $poi_id=&sql_get($dbh,"select id from COLLECTE_GPS_EDIF where album_id=$album_id;");

		my $type='église';
		if (($title=~/abbatiale/i)||($name=~/abbatiale/i)) { $type='abbatiale';};
		if (($title=~/abbaye/i)||($name=~/abbaye/i)) { $type='abbaye';};
		if (($title=~/basilique/i)||($name=~/basilique/i)) { $type='basilique';};
		if (($title=~/cathédrale/i)||($name=~/cathédrale/i)) { $type='cathédrale';};
		if (($title=~/chapelle/i)||($name=~/chapelle/i)) { $type='chapelle';};
		if (($title=~/collégiale/i)||($name=~/collégiale/i)) { $type='collégiale';};
		if (($title=~/couvent/i)||($name=~/couvent/i)) { $type='couvent';};
		if ($epoch_style=~/civil/i) { $type='civil';};
		if ($epoch_style=~/renaissance/i) { $type='civil';};

		$town=~s/\'/\\\'/g;
		$name=~s/\'/\\\'/g;
		$type=~s/\'/\\\'/g;

		print "#$title\nUPDATE COLLECTE_GPS_EDIF SET epoch_style='$epoch_style',name='$name',type='$type' WHERE id=$poi_id;\n";
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


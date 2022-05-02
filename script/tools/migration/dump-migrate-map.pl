#!/usr/bin/perl
# generate sernum from photo name

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

$debug=1;

$sql = "select id, album_id, map_url, map_img_low, map_source_text, map_source_url, map_source_book_id, place_id, map_img_site from map";
$sth = $dbh->prepare($sql);
$sth->execute();

my ($id, $album_id, $map_url, $map_img_low, $map_source_text, $map_source_url, $map_source_book_id,$place_id, $map_img_site);
$sth->bind_columns(\$id, \$album_id, \$map_url, \$map_img_low, \$map_source_text, \$map_source_url, \$map_source_book_id, \$place_id, \$map_img_site);

while ($sth->fetch()) {

	#print "image_type=3\n";
	$map_url2=$map_url;
	$map_url2=~s/\.m\.jpg$/\.jpg/;
	$map_url2=~s/.*\///;
	#print "original_file=$map_url2\n";
	$map_img_low=~s/.*\///;
	#print "thumb_file=$map_img_low\n";
	$map_url=~s/.*\///;
	#print "image_file=$map_url\n";
	#print "site_img=6\n";
	#print "site_thb=6\n";
	#print "place_id=$place_id\n";
	#print "source_type=2\n";
	#print "source_type_ref_id=$map_source_book_id\n";
	#print "source_url=$map_source_url\n";
	#print "\n";

	my $sql="SELECT id FROM photo where original_file='$map_url2'";
	if ($debug) {print $sql."\n";}
	my $r_id=&sql_get($dbh,$sql);
	if (!$r_id) {
		$sql="INSERT INTO photo (id,image_type,original_file,thumb_file,image_file,site_img,site_thb,place_id) VALUES (null,3,'$map_url2','$map_img_low','$map_url',6,6,$place_id)";
		if ($debug) {print $sql."\n";}
		&sql_update($dbh,$sql);

		$sql="SELECT id FROM source where type_ref_id='$map_source_book_id'";
		if ($debug) {print $sql."\n";}
		my $s_id=&sql_get($dbh,$sql);

		
		if (!$s_id) {
			$sql="INSERT INTO source (id,type,type_ref_id,url,display_text) VALUES (null,2,$map_source_book_id,'$map_source_url','$map_source_text');\n";
			if ($debug) {print $sql."\n";}
			&sql_update($dbh,$sql);
		}

		$sql="SELECT id FROM photo where original_file='$map_url2'";
		if ($debug) {print $sql."\n";}
		$r_id=&sql_get($dbh,$sql);

		my $sql="INSERT INTO map_album (map_id,album_id) VALUES ($r_id,$album_id);\n";
		if ($debug) {print $sql."\n";}
		&sql_update($dbh,$sql);
	}
}


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


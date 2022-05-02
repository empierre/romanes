#!/usr/bin/perl
# generate sernum from photo name

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


$sql = "select id, album_id, map_url, map_img_low, map_source_text, map_source_url, map_source_book_id, place_id, map_img_site from map";
$sth = $dbh->prepare($sql);
$sth->execute();

my ($id, $album_id, $map_url, $map_img_low, $map_source_text, $map_source_url, $map_source_book_id,$place_id, $map_img_site);
$sth->bind_columns(\$id, \$album_id, \$map_url, \$map_img_low, \$map_source_text, \$map_source_url, \$map_source_book_id, \$place_id, \$map_img_site);

while ($sth->fetch()) {

	print "id=$id\nalbum_id=$album_id\nmap_url=$map_url\nmap_img_low=$map_img_low\nmap_source_text=$map_source_text\nmap_source_url=$map_source_url\nmap_source_book_id=$map_source_book_id\nplace_id=$place_id\nmap_img_site=$map_img_site\n";
	print "\n";

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


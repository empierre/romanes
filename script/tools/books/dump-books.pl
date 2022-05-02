#!/usr/bin/perl
# generate sernum from photo name

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


$sql = "select id,groupe,editor,collection,author,title,lang,year,isbn,url,url_picture,description_file from book";
$sth = $dbh->prepare($sql);
$sth->execute();

my ($id,$groupe,$editor,$collection,$author,$title,$lang,$year,$isbn,$url,$url_picture,$description_file);
$sth->bind_columns(\$id,\$groupe,\$editor,\$collection,\$author,\$title,\$lang,\$year,\$isbn,\$url,\$url_picture,\$description_file);

while ($sth->fetch()) {

	print "id=$id\ngroupe=$groupe\neditor=$editor\ncollection=$collection\nauthor=$author\ntitle=$title\nlang=$lang\nyear=$year\nisbn=$isbn\ndescription_file=$description_file\n";
	#1=local 2=amazon 3=alapage 4=abebooks
	if     ($url=~/amazon/) {print"is_available_from=2\n"}
	elsif  ($url=~/alapage/) {print"is_available_from=3\n"}
	elsif  ($url=~/abebooks/) {print"is_available_from=4\n"}
	if ($url) {print "is_available_url=$url\n";}
	#1=local 2=amazon 3=alapage 4=abebooks
	if     ($url_picture=~/amazon/) {print"has_picture_from=2\n"}
	elsif  ($url_picture=~/alapage/) {print"has_picture_from=3\n"}
	elsif  ($url_picture=~/abebooks/) {print"has_picture_from=4\n"}
	if ($url_picture) {print "has_picture_url=$url\n";}
	#1=book 2=cd 3=dvd
	print "media=1\n";
	my $classification=&get_classification($id);
	print "classification=$classification\n";
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


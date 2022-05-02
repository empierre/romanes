#!/usr/bin/perl
#
# Sync GPS and place from list
#
# format: lon,lat,gps_id
#

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


open(FIC,$ARGV[0])||die "$! not found\n";
while(<FIC>) {
	 next if (/^#/);
	 next if (/^\n/);
	 chomp;
	 my ($lon,$lat,$gps_id)=split(/,/,$_);
	 $lon=~s/ //g;
	 $lat=~s/ //g;
	 my $album_id=&sql_get($dbh,"select album_id from COLLECTE_GPS_EDIF where id=$gps_id");
	 #print STDERR "$album_id-";
	 my $place_id=&sql_get($dbh,"select distinct place_id from album_place where album_id=$album_id");
	 #print STDERR "$place_id-\n";

	 print "update COLLECTE_GPS_EDIF set lon='$lon',lat='$lat' where id=$gps_id;\n";
	 print "update place set lng='$lon',lat='$lat' where id=$place_id;\n";

}
close(FIC);

$sth1->finish();
#$sth2->finish();
#$sth->finish();
exit;


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


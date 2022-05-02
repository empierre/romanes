#!/usr/bin/perl
# generate sernum from photo name

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES2",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


	#$sql = "select id, sernum, author_id, original_file ,place_id from photo where sernum =\'\'";
	$sql = "select id, sernum, author_id, original_file ,place_id from photo";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($id, $sernum, $author_id, $original_file, $place_id);
	$sth->bind_columns(\$id, \$sernum, \$author_id, \$original_file, \$place_id);

	while ($sth->fetch()) {

		($sernum)=($original_file=~/_*([0-9\-\.]+)\.jpg$/);

		($sr1,$seq1)=($sernum=~/^\-?(\d+)\-(\d+)/);

		if (!((length($sr1)<4)||(length($seq1)<2))) {

			#print "$original_file -> $sernum -> $sr1 $seq1\n";
			print "update photo set sernum=$sr1,ref='$author_id-$place_id-$sr1-$seq1-$id' where id=$id;\n";

		} elsif ((length($sr1)==3)&&(length($seq1)==3)) {

			($sr1,$sr2,$seq1)=($sernum=~/^\-?(\d+)\-(\d+)-(\d+)/);
			$sn="$sr1$sr2";
			print "update photo set sernum=$sn,ref='$author_id-$place_id-$sn-$seq1-$id',camera_id=10,lens_id=0 where id=$id;\n";

		} else {
			print "update photo set ref='$author_id-$place_id-$id' where id=$id;\n";

		}
	

	}
	$sth->finish();


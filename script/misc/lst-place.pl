#!/usr/bin/perl
# generate sernum from photo name

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


	$sql = "select id, town,postcode from place";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($id, $town, $postcode);
	$sth->bind_columns(\$id, \$town, \$postcode);

	while ($sth->fetch()) {

		print "$id;$town;$postcode;\n";	

	}
	$sth->finish();


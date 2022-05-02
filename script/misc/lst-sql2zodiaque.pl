#!/usr/bin/perl
# SQL book table to active Zodique books

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES2",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


	$sql = "select collection, author, title, url, url_picture,isbn from book where url LIKE \"http%\" AND editor LIKE \"Zodiaque\" ORDER BY collection, title";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($collection,$author,$title,$url,$url_picture,$isbn);
	$sth->bind_columns(\$collection,\$author,\$title,\$url,\$url_picture,\$isbn);

	while ($sth->fetch()) {

		if ($url_picture=~//) {
			my $res= "<tr><td><a href=\"$url\"><img src=\"$url_picture\" border=\"0\"></a> </td><td> <a class=\"blackbar\" href=\"$url\">$title - $author - $collection - Zodiaque</a> </td></tr> \n";
			$res=~s/null -//;
			print $res;
		}
	

	}
	$sth->finish();


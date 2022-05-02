#!/usr/bin/perl
# SQL book table to active Zodique books

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES2",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


	$sql = "select id,collection, author, title, url, url_picture,isbn from book where editor LIKE \"Zodiaque\" ORDER BY collection, title";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($id,$collection,$author,$title,$url,$url_picture,$isbn);
	$sth->bind_columns(\$id,\$collection,\$author,\$title,\$url,\$url_picture,\$isbn);

	while ($sth->fetch()) {

#print STDERR "1 url_picture=$url_picture\n";
		if ($url_picture=~/www\.amazon\.fr/) {
#print STDERR "2 url_picture=$url_picture\n";
			
				($isbn)=($url_picture=~/.*\/ASIN\/([^\/]+)\/.*/);
#print STDERR "3 url_picture=$url_picture\n";

					if ($isbn) {
						print "update book set isbn=\'$isbn\',url_picture=\'http://images-eu.amazon.com/images/P/$isbn.08.MZZZZZZZ.jpg\' where id=$id;\n";
					} else {
						print "BAD:".$url_picture."\n";
					}
			}
	

	}
	$sth->finish();


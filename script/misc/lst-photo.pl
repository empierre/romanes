#!/usr/bin/perl
# generate sernum from photo name

use DBI();

my %web_host_img=(
    "8" => "http://www.romanes.com/",
    "1" => "http://romanes.free.fr/",
    "2" => "http://romanes2.free.fr/",
    "3" => "http://romanes3.free.fr/",
    "4" => "http://romanes4.free.fr/",
    "5" => "http://emmanuel.pierre2.free.fr/",
    "6" => "http://aaea.free.fr/",
    "7" => "http://aaea2.free.fr/"
);

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


	$sql = "select id, original_file, site_img from photo";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($id, $town, $postcode);
	$sth->bind_columns(\$id, \$original_file, \$site_img);

	while ($sth->fetch()) {

		print "$id;$original_file;".$web_host_img{$site_img}."$original_file;\n";	

	}
	$sth->finish();


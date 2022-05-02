#!/usr/bin/perl

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


$sql = "select id,title from album";
$sth = $dbh->prepare($sql);
$sth->execute();

$sth->bind_columns(\$a_id,\$a_t);

while ($sth->fetch()) {
  print "$a_id;$a_t;\n";
}
$sth->finish();

#!/usr/bin/perl
#
# Removes photos not in album_photo
#
use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

#List all photos
$sql = "select id from photo order by id";
$sth = $dbh->prepare($sql);
$sth->execute();
$sth->bind_columns(\$id);

while ($sth->fetch()) {
  #print "$a_id;$a_t;\n";
  $photo{$id}=1;
}
$sth->finish();

#List all photos in album
$sql = "select photo_id from album_photo order by photo_id";
$sth = $dbh->prepare($sql);
$sth->execute();
$sth->bind_columns(\$id);

while ($sth->fetch()) {
  #print "$a_id;$a_t;\n";
  $photo{$id}+=2;
}
$sth->finish();

foreach $key (keys %photo) {
  if ($photo{$key}<2) {
	print "DELETE FROM photo where id=$key;\n";
  }
}

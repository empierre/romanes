#!/usr/bin/perl -w

use misc;

use Image::Info qw(image_info);
use DBI();

$dbh = DBI->connect("DBI:mysql:ROMANES3:127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

print &misc::simple_get($dbh,"select count(*) from photo;");

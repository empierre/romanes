#!/usr/bin/perl
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
#use strict;

#Updated for templates/pages/regions

# Make a list of site per regions

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


my $debug=0;



        my $sql="select id,postcode,country from place where department_id is NULL";
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        if ($sth->rows>0) {
            my ($id,$postcode,$country);
            $sth->bind_columns(\$id,\$postcode,\$country);
            while ($sth->fetch()) {
				if (($country=250)&&(length($postcode)==5)) {
					my $department=substr($postcode,0,2);
					print "UPDATE place SET department_id='$department' where id=$id;\n";		
				}	
            }
        }



$dbh->disconnect; 
print STDERR "Done\n";
exit;

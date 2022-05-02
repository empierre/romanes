#!/usr/bin/perl
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;

# Gnerate a plan list per region

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

    open(FIC,"add_geoloc.txt");		
	while(<FIC>) {
		# 5;Caen;14000;49.1847;-0.3601
		chomp;
		my ($id,$town,$postcode,$lat,$lng)=split(/;/,$_);	
		print "UPDATE place SET lng='$lng',lat='$lat' where id=$id;\n";
	}

	close(FIC);

$dbh->disconnect;
print STDERR "ok\n";
exit;



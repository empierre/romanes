#!/usr/bin/perl
#
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
use Encode;
#use strict;

#Updated for templates/pages/regions
# Make a list of site per regions

#version
my $version_dev="1.0.5d";
my $debug=0;
my $regenerate=0;

#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

# Parameters
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];

if (! -d $out_dir) {
	mkdir $out_dir;
} else {
	#print "rm $out_dir/*";
    `rm $out_dir/*`;
}

my @lang_param=('fr','en','es','it');
foreach $lang (@lang_param) {
    $lang='_'.$lang;
	if ($lang eq '_fr') {$lang='';}
	open(FIC,"> $out_dir/index$lang.html");
	print FIC "<HTML><HEAD><SCRIPT language=\"javascript1.3\">window.location.href=\"http://www.romanes.org/$out_dir/index$lang.html\";</SCRIPT></HEAD></HTML>";
	close(FIC);
}

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");

&sql_update($dbh,"update album set onsite=9 where id=$album_id");

`./script/make-album.pl -l $album_id $out_dir fr fr:en:es:it`;

exit;

sub sql_update {
	my ($dbh,$sql) = @_;
	my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
	return($rc);
}


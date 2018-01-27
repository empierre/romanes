#!/usr/bin/perl 
#
# (c) 2002-2004 Emmanuel PIERRE
#          epierre@e-nef.com
#          http://www.e-nef.com/users/epierre

#use lib qw (/usr/local/etc/httpd/sites/e-nef.com/htdocs/cgibin/);
#use strict;
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
use Encode;
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
use open IO => ":utf8",":std";
use utf8;
use Encode;
use Text::Unidecode;


#version
my $version_dev="1.0.5utf8";
my $debug=0;

#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

#
# Command Line Options Analysis
#
my %opts;
getopt('a', \%opts);


# Parameters
my $album_ids=$ARGV[0];


# Global data
my $t_header;
my $t_content;
my $t_footer;
#my $photo_dir="http://perso.orange.fr/e-nef/";
#my $photo_thumb_dir="http://perso.orange.fr/e-nef/";

#my $photo_wp800x600_dir="http://romanes.free.fr/wp-800x600/";
#my $photo_wp1024x768_dir="http://romanes2.free.fr/wp-1024x768/";

my %web_host_img=(
	"9" => "http://www.romanes.org/",
	"8" => "http://www.romanes.com/",
	"1" => "http://romanes.free.fr/",
	"2" => "http://romanes2.free.fr/",
	"3" => "http://romanes3.free.fr/",
	"4" => "http://romanes4.free.fr/",
    "5" => "http://emmanuel.pierre2.free.fr/",
    "6" => "http://aaea.free.fr/",
    "7" => "http://aaea2.free.fr/",
    "11" => "http://romanes11.free.fr/",
    "12" => "http://romanes12.free.fr/"
);
my %web_host_thb=(
	#"1" => "http://perso.orange.fr/e-nef/"
        "1" => "http://www.romanes.org/"
);
my %web_host_album=(
        "11" => "http://romanes11.free.fr/",
        "12" => "http://romanes12.free.fr/",
        "9" => "http://www.romanes.org/",
        "8" => "http://www.romanes.com/",
        "1" => "http://romanes.free.fr/",
        "2" => "http://romanes2.free.fr/",
        "3" => "http://romanes3.free.fr/",
        "4" => "http://romanes4.free.fr/",
    "5" => "http://emmanuel.pierre2.free.fr/",
    "6" => "http://aaea.free.fr/",
    "7" => "http://aaea2.free.fr/"
);

if (! -d $out_dir) {
	mkdir $out_dir;
}

my $local_tmpl="/mnt/data/web/dev/romanes2.com/templates/";
my $photo_album_file="index.html";

my @tab_site_region_next=();
my @tab_site_region_id=();

# DB Connection
my $dbh2 = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef,{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

#
# Get the Album data
#
my $sql = "SELECT id,url FROM album where id in ($album_ids) ORDER BY id";
if ($debug) {print STDERR $sql."\n";}
my $sth_id = $dbh2->prepare($sql);
$sth_id->execute();

my ($album_url,$album_id);
my ($url,$id);
$sth_id->bind_columns(\$id,\$url);

while ($sth_id->fetch()) {
	$album_url=$url;$album_id=$id;
	$album_url=~s/^\///;
	print "./script/make-album.pl -l $album_id $album_url $ARGV[1] $ARGV[2]\n";
	`/usr/bin/perl ./script/make-album.pl -l $album_id $album_url $ARGV[1] $ARGV[2]`;
}
$sth_id->finish();

$dbh2->disconnect;

exit;

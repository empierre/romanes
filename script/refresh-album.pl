#!/usr/bin/perl
#
# Refresh the album data
#
#
use Image::Info qw(image_info);
use DBI();
use Date::Manip;
use Getopt::Std;
use Fcntl;
use Encode;
#my $encoding = 'utf8';
#binmode(STDOUT, ":utf8");
#binmode(STDIN, ":utf8");
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
#use open IO => ":utf8",":std";
use utf8;
use Text::Unidecode;


#version
my $version_dev="1.0.6utf8";

#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

$debug=1;

$dbh = DBI->connect("DBI:mysql:ROMANES3:127.0.0.1",'root',undef,{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");



# Get command line parameter
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];

# Get the Album data
my $sql = "SELECT title FROM album where id=$album_id";
if ($debug) {print $sql."\n";}
my $album_title=&sql_get($dbh,$sql);
print STDERR "Album $album_id: $album_title\n";

my $sql = "SELECT comment_id FROM album where id=$album_id";
if ($debug) {print $sql."\n";}
my $comment_id=&sql_get($dbh,$sql);


#
# Reresh DB
#

# Opens Album.idx
if ($debug) {print STDERR "Opening album.idx\n";}
open(ALB, "<:encoding(UTF-8)","$out_dir/album.idx")||warn "no album!\n";
my $onsite,$onsite_thb,$onsite_img;
    while (<ALB>) {
        chomp;
        if (/^onsite:/) {
            ($tmp,$onsite)=split(/:/,$_);
            if (!$onsite_img) {$onsite_img=$onsite;}
            if (!$onsite_thb) {$onsite_thb=$onsite;} }
        if (/^onsite_img/) {
            ($tmp,$onsite_img)=split(/:/,$_);
            if (!$onsite_img) {$onsite_img=1;} }
        if (/^onsite_thb/) {
            ($tmp,$onsite_thb)=split(/:/,$_);
            if (!$onsite_thb) {$onsite_thb=1;} }
        if (/^epoch:/) {
            ($tmp,$epoch)=split(/:/,$_); }
        if (/^epoch_style/) {
            ($tmp,$epoch_style)=split(/:/,$_); }
        if (/^epoch_str/) {
            ($tmp,$epoch_str)=split(/:/,$_); }
        if (/^description/) {
            ($tmp,$description)=(/^(description):"(.*)"/); }
        if (/^classification/) {
            ($tmp,$classification)=split(/:/,$_); }
        if (/^title/) {
            ($tmp,$title)=split(/:/,$_); }
        if (/^url/) {
            ($tmp,$url)=split(/:/,$_); }
        if (/^order/) {
            ($tmp,$display_order)=split(/:/,$_); }
        if (/^map_url/) { ($tmp,$map_url)=split(/:/,$_)};
        if (/^map_img_low/) {($tmp,$map_img_low)=split(/:/,$_)};
        if (/^map_source_text/) {($tmp,$map_source_text)=split(/:/,$_)};
        if (/^map_source_url/) {($tmp,$map_source_url)=split(/:/,$_)};
        if (/^map_source_book_id/) {($tmp,$map_source_book_id)=split(/:/,$_)};
}
close(ALB);

$title=~s/\'/\\\'/g;
if (!($display_order)) {$display_order=1;}

if ($epoch) {
	$sql="UPDATE album set url=\'$url\',title=\'$title\',epoch=$epoch,epoch_style=\'$epoch_style\',epoch_str=\'$epoch_str\',display_order=$display_order where id=$album_id";
} else {
	$sql="UPDATE album set url=\'$url\',title=\'$title\',display_order=$display_order where id=$album_id";
}
if ($debug) { print STDERR $sql."\n";}
&sql_update($dbh,$sql);

if ($description eq '') {
#backward comp.
	# Opens photo.idx
	if ($debug) {print STDERR "Opening the photo.idx\n";}
	open(PHO,"$out_dir/photo.idx")||die "no photo.idx!\n";
	    while (<PHO>) {
		chomp;
		if ($debug) {print STDERR "$_\n";}
		if (/^description/) {
            ($tmp,$description)=(/^(description):"(.*)"/); }
		if (/^map_url/) { ($tmp,$map_url)=split(/:/,$_)};
		if (/^map_img_low/) {($tmp,$map_img_low)=split(/:/,$_)};
		if (/^map_source_text/) {($tmp,$map_source_text)=split(/:/,$_)};
		if (/^map_source_url/) {($tmp,$map_source_url)=split(/:/,$_)};
		if (/^map_source_book_id/) {($tmp,$map_source_book_id)=split(/:/,$_)};
	}
	close(PHO);
}
$description=~s/\'/\\\'/g;
$description=~s/^"//;
$description=~s/"$//;
if ($description) {
	my $sql="UPDATE strings SET text=\'$description\' WHERE id_l=$comment_id and lang='fr'";
	if ($debug) { print STDERR $sql."\n";}
	&sql_update($dbh,$sql);
}

if ($debug) {print "select place_id from album_place where album_id=$album_id\n";}
if (&sql_get($dbh,"select place_id from album_place where album_id=$album_id") != $place_id) {
#if (&sql_get($dbh,"select place_id from album_place where album_id=$album_id and place_id=$place_id") != $place_id) {
	my ($i2,$i3,$place_id)=&get_author_creation_place($out_dir);
	$sql="INSERT INTO album_place (album_id,place_id) VALUES ($album_id,$place_id)";
	if ($debug) { print STDERR $sql."\n";}
	&sql_update($dbh,$sql);
}
exit;

#
# Classification
#
my @classification_id=split(/,/,$classification);
foreach $c_id (@classification_id) {
	my $sql="SELECT id_rel FROM album_classification WHERE album_id=$album_id and id_rel=$c_id";
	if ($debug) { print STDERR $sql."\n";}
	my $res=&sql_get($dbh,$sql);
	if ($res eq '') {
		my $sql="INSERT INTO album_classification (album_id,id_rel) VALUES ($album_id,$c_id)";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);
	}
}

#
# Map
#
if ($map_img_low) {
	if ($debug) { print STDERR "Start MAP \n";}
        if (!$map_source_book) {$map_source_book=0;}

	# Get map_id
	#PB my $sql = "SELECT map_album.map_id from map_album where map_album.album_id=$album_id";
	my $sql = " SELECT id from map where map_img_low='$map_img_low'";
	if ($debug) { print STDERR $sql."\n";}
	my $map_id=&sql_get($dbh,$sql);

	if ($map_id>0) {
		my $sql = "UPDATE map SET map_url='$map_url',map_img_low='$map_img_low',map_source_text='$map_source_text',map_source_url='$map_source_url',map_source_book_id='$map_source_book_id' WHERE id=$map_id;";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);
	} else {
		my $sql = "INSERT INTO map (id,album_id,map_url,map_img_low,map_source_text,map_source_url,map_source_book_id) VALUES (null,$album_id,'$map_url','$map_img_low','$map_source_text','$map_source_url',$map_source_book_id);";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);

		my $sql="SELECT id from map where map_img_low='$map_img_low'";
		my $map_id=&sql_get($dbh,$sql);

		my $sql = "INSERT INTO map_album (map_id,album_id) VALUES ($map_id,$album_id);";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);

	}
} else {
	if ($debug) { print STDERR "No MAP \n";}

}

#
# Sync books
#

my $sql="select book_album.book_id,book_album.display_order,book.title from book_album,book where book_album.album_id=$album_id and book_album.book_id=book.id";
my $sth = $dbh->prepare($sql);
$sth->execute();

my ($i1,$i2,$i3);
$sth->bind_columns(\$i1,\$i2,\$i3);

while ($sth->fetch()) {
	$ind{$i1}=$i2;
}

#
# books.idx sync
#
if (-e "$out_dir/books.idx") {
	if ($debug) {print STDERR "Start Books\n";}
	open(FIC,"$out_dir/books.idx")||die"Error: books.idx: $!";;
	my $fic_cnt=1;
	while(<FIC>) {
		next if (/^#/);
		chomp;
		my $fic=$_;
		if (!$newind{$fic}) {
			if ($debug) {print STDERR "$fic -> $fic_cnt\n";}
			$newind{$fic}=$fic_cnt++;
		} else {
			print "$fic is duplicate\n";
		}
	}
	close(FIC);
	
	foreach $key (keys %newind) {
	     if ($ind{$key} ne '') {
	     #Key exist
		if (!($newind{$key}==$ind{$key})) {
		# Order has changed
			print "$key#".$ref{$key}." update from ".$ind{$key}." to ".$newind{$key}."\n";
			my $sql="UPDATE book_album set display_order=".$newind{$key}.",publish=1 WHERE book_id=" .$ref{$key}." AND album_id=$album_id";
			if ($debug) {print STDERR "$sql\n";}
			&sql_update($dbh,$sql);
		} # else no change
	     } else {
			#NEW 
			print "$key new at ".$newind{$key}."\n";
			my $sql="INSERT INTO book_album (album_id,book_id,display_order,publish) values ($album_id,$key,".$newind{$key}.",1)";
			if ($debug) {print STDERR "$sql\n";}
			&sql_update($dbh,$sql);
	     }
	}
	foreach $key (keys %ind) {
		if ((!$newind{$key} ne '')&&($ind{$key}>0)) {
			print "$key#".$ref{$key}." removed from ".$ind{$key}."\n";
			my $sql="UPDATE book_album SET display_order=0,publish=0 WHERE book_id=".$key." AND album_id=$album_id";
			if ($debug) {print STDERR "$sql\n";}
			&sql_update($dbh,$sql);
		}
	}
} else {
	if ($debug) {print STDERR "No Books\n";}
}



# Close DB connection
if ($debug) {print STDERR "Database disconnection\n";}
$dbh->disconnect;

print "Done\n";


sub sql_get {
	my ($dbh,$sql) = @_;

	my $sth = $dbh->prepare($sql);
	$sth->execute();

	my $res;my $r;
	$sth->bind_columns(\$res);

	while ($sth->fetch()) {
	    $r=$res;
	}
	$sth->finish();

	return($r);
}
sub sql_delete {
	my ($dbh,$sql) = @_;
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}

sub sql_update {
	my ($dbh,$sql) = @_;
	my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
	return($rc);
}

sub get_author_creation_place {
	my ($out_dir)=@_;
	open(PHO,"$out_dir/photo.idx")||die"Error: $out_dir/photo.idx: $!";
	if ($debug) {print STDERR "Opening  $out_dir/photo.idx (sub)\n";}
	my $i1||0,$i2||0,$i3||0,$i4||0;my $tmp;
	while (<PHO>) {
		chomp;
		#if ($debug) {print STDERR "$_\n";}
		if (/^author_id/){ ($tmp,$i2)=split(/:/,$_);if (($i2<0)&&($i2>200)) {$i2=1;};if ($i2 eq '') {$i2=0;}; }
		if (/^creation/) { ($tmp,$i3)=split(/:/,$_); }
		if (/^place_id/) { ($tmp,$i4)=split(/:/,$_);if (($i4<0)&&($i4>200)) {$i4=0;};if ($i4 eq '') {$i4=0;}; }
	}
	close(PHO);
	return($i2,$i3,$i4);
}

1;

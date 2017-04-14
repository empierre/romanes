#!/usr/bin/perl
#
# Refresh the image list for an album
#
#
# version:1.0.1utf8
#
#   

use Image::Info qw(image_info);
use Digest::MD5::File qw(dir_md5_hex file_md5_hex url_md5_hex);
use DBI();
#use misc;
use Encode;
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
#use open IO => ":utf8",":std";
use utf8;
use Encode;
use Text::Unidecode;

#version
my $version_dev="1.0.1utf8";
#$debug=1;

$dbh = DBI->connect("DBI:mysql:ROMANES3:127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");


# Get command line parameter
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];

# Get the Album data
my $sql = "SELECT title FROM album where id=$album_id";
my $album_title=&sql_get($dbh,$sql);
print STDERR "Album $album_id: $album_title\n";


#
# Delete the Photo Album data
#
#my $sql = "SELECT photo.id FROM photo,album_photo where album_photo.album_id=$album_id AND album_photo.photo_id=photo.id";
#my $sth = $dbh->prepare($sql);
#$sth->execute();

#my ($sid,$id,$plist);
#$sth->bind_columns(\$sid);

#while ($sth->fetch()) {
#	if (!$plist) {
#		$plist=$sid;
#	} else {
#		$plist.=",".$sid;
#	}
#}
#$sth->finish();


#
# Reresh DB
#

my %ref;my %ind;my %newind;
my $sql="select album_photo.photo_id,album_photo.display_order,photo.original_file from album_photo,photo where album_photo.album_id=$album_id and album_photo.photo_id=photo.id";
my $sth = $dbh->prepare($sql);
$sth->execute();

my ($i1,$i2,$i3);
$sth->bind_columns(\$i1,\$i2,\$i3);

while ($sth->fetch()) {
	$ref{$i3}=$i1;
	$ind{$i3}=$i2;
	if ($debug) {print "ind $i3 = $i2\n";}
}

# Opens Album.idx
if ($debug) {print STDERR "Opening album.idx\n";}
open(ALB,"$out_dir/album.idx")||die "no album!\n";
my $onsite,$onsite_thb,$onsite_img;
    while (<ALB>) {
        chomp;
        if (/^onsite/) {
            ($tmp,$onsite)=split(/:/,$_);
            if (!$onsite_img) {$onsite_img=$onsite;}
            if (!$onsite_thb) {$onsite_thb=$onsite;}
        }
        if (/^onsite_img/) {
            ($tmp,$onsite_img)=split(/:/,$_);
            if (!$onsite_img) {$onsite_img=1;} }
        if (/^onsite_thb/) {
            ($tmp,$onsite_thb)=split(/:/,$_);
            if (!$onsite_thb) {$onsite_thb=1;} }
}
close(ALB);

#
# images.idx sync
#
open(IDX,"$out_dir/images.idx")||die"Error: images.idx: $!";;
if ($debug) {print STDERR "Opening images.idx\n";}
$_=<IDX>;

# Update Album URL
my $albumurl=<IDX>;
chomp($albumurl);
my $sql = "UPDATE album SET url='$albumurl' where id=$album_id;";
if ($debug) {print STDERR "$sql\n";}
&sql_update($dbh,$sql);

close(IDX);

#
# images.idx sync
#
open(FIC,"$out_dir/images.idx")||die"Error: images.idx: $!";;
<FIC>; <FIC>; <FIC>;
my $fic_cnt=1;
while(<FIC>) {
        next if (/^#/);
        chomp;
        my $fic=$_;
	$fic=~s/ /\ /g;
		if (!-e "$out_dir/$fic") {warn "WARNING $out_dir/$fic not found!\n";}
        if (!$newind{$fic}) {
		if ($debug) {print STDERR "$fic -> $fic_cnt\n";}
                $newind{$fic}=$fic_cnt++;
        } else {
                if ($debug) {print "$fic is duplicate\n";}
        }
}
close(FIC);

foreach $key (keys %newind) {
next if ($key eq '');
     if ($ind{$key} ne '') {
     #Key exist
        if (!($newind{$key}==$ind{$key})) {
        # Order has changed
                if ($debug) {print "$key#".$ref{$key}." update from ".$ind{$key}." to ".$newind{$key}."\n";}
				my $sql="UPDATE album_photo set display_order=".$newind{$key}.",publish=1 WHERE photo_id=" .$ref{$key}." AND album_id=$album_id";
				if ($debug) {print STDERR "$sql\n";}
				&sql_update($dbh,$sql);
				my $sql="UPDATE photo SET site_img=$onsite_img,site_thb=$onsite_thb where id=" .$ref{$key};
				#if ($debug) {print STDERR "$sql\n";}
				&sql_update($dbh,$sql);
		} else {
				# else no change ?
				my $md5 = Digest::MD5->new;
				$md5->addpath("$out_dir/$key");
				my $digest = $md5->hexdigest;

				my $sql="select md5 from photo where id=" .$ref{$key};
				#if ($debug) {print STDERR "$sql\n";}
				my $photo_md5=&sql_get($dbh,$sql);
	
				if ($digest ne $photo_md5) {
						if ($debug) {print STDERR "$key has changed\n";}
						my $sql="UPDATE photo SET site_img=$onsite_img,site_thb=$onsite_thb,md5='$digest' where id=" .$ref{$key};
						#if ($debug) {print STDERR "$sql\n";}
						&sql_update($dbh,$sql);
				}
		}
     } else {
		#NEW 
                if ($debug) {print "$key new at ".$newind{$key}."\n";}
                &photo_insert($key,$out_dir,$newind{$key});
     }
}
foreach $key (keys %ind) {
        if (!$newind{$key} ne '') {
                if ($debug) {print "$key#".$ref{$key}." removed from ".$ind{$key}."\n";}
                my $sql="UPDATE album_photo SET display_order=0,publish=0 WHERE photo_id=".$ref{$key};
		if ($debug) {print STDERR "$sql\n";}
                &sql_update($dbh,$sql);
        }
}

# Close DB connection
if ($debug) {print STDERR "Database disconnection\n";}
$dbh->disconnect;

print "Done\n";



sub photo_insert {
	my ($myfile,$outdir,$new_index)=@_;
	if (!(-e "$out_dir/$myfile")) {next;}
	my $info = image_info("$out_dir/$myfile");
	my $width  = $info->{width};
	my $height = $info->{height};

	my $md5 = Digest::MD5->new;
	$md5->addpath("$out_dir/$myfile");
	my $digest = $md5->hexdigest;


        if (($height<1)||($width<1)) {next;}

        if ($debug) {print STDERR "#Working on $myfile\n"};
		next if (/#/);

		if (!(-e "$out_dir/$myfile")) {
			print STDERR "Warning: $out_dir/$myfile doesn not exist ! \n";
			next;
		}
		$myfile=~s/\ /\\ /g;
		if ($debug) {print "#Working on $myfile\n";}

		# Insert Photo
		my $thumbfile="thb-".$myfile;
		$thumbfile=~tr/\ /_/;
		$album_name=~tr/'/\\'/;
		my ($i2,$i3,$i4)=&get_author_creation_place($out_dir);
		$i1=&generate_sernum($myfile,$i2,$i3,$i4,0);
	

		my $sql = "INSERT INTO photo (id,sernum,author_id,creation,place_id,resolution_x,resolution_y,description,original_file,thumb_file,name,site_img,site_thb,md5) VALUES (null,'$i1',$i2,'$i3',$i4,$height,$width,'','$myfile','$thumbfile','$album_name',$onsite_img,$onsite_thb,'$digest');";
		if ($debug>1) {print STDERR $sql."\n"};
		my $rc = &sql_update($dbh,$sql);

		# Get photo id
		my $sql="SELECT id from photo where original_file='$myfile' ORDER BY id";
		my $photo_id=&sql_get($dbh,$sql);

		# Update sernum
		my $sql	="UPDATE photo SET sernum=\'".&generate_sernum($myfile,$i2,$i3,$i4,$photo_id)."\' where id=$photo_id";
		if ($debug) {print STDERR "$sql\n";}
		&sql_update($dbh,$sql);

		# Insert Photo-Album relationship
		my $sql =  "INSERT INTO album_photo (album_id,photo_id,display_order,publish) VALUES ($album_id,$photo_id,$new_index,1);";
		if ($debug) {print STDERR "$sql\n";}
		my $rc = &sql_update($dbh,$sql);

}

sub get_author_creation_place {
	my ($out_dir)=@_;
	open(PHO,"$out_dir/photo.idx")||die"Error: $out_dir/photo.idx: $!";
	if ($debug) {print STDERR "Opening  $out_dir/photo.idx\n";}
	my $i1||0,$i2||0,$i3||0,$i4||0;my $tmp;
	while (<PHO>) {
		chomp;
		if (/^author_id/){ ($tmp,$i2)=split(/:/,$_);if (($i2<0)&&($i2>200)) {$i2=1;};if ($i2 eq '') {$i2=0;}; }
		if (/^creation/) { ($tmp,$i3)=split(/:/,$_); }
		if (/^place_id/) { ($tmp,$i4)=split(/:/,$_);if (($i4<0)&&($i4>200)) {$i4=0;};if ($i4 eq '') {$i4=0;}; }
	}
	close(PHO);
	return($i2,$i3,$i4);
}

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

sub generate_sernum {
	my ($original_file,$author_id,$creation_date,$place_id,$id) = @_;

	my $sql="SELECT postcode FROM place WHERE id=$place_id";
	my $postcode=&sql_get($dbh,$sql);

	my $sql="SELECT country FROM place WHERE id=$place_id";
	my $country=&sql_get($dbh,$sql);

	# S/R procedure
	($seq1)=($original_file=~/.*([0-9]+)\.jpg$/);
	#AAAOO-NNN-DDDD-XXXX
	my $lg=length($seq1);
	for($i=$lg;$i<4;$i++) {
		$seq1="0".$seq1;
	}
	my $sr="$country-$postcode-$seq1-$id";
	return($sr);
}

1;

#!/usr/bin/perl
#
# Creates a new album
#
#
# version:1.0.1-utf8
#
use Image::Info qw(image_info);
use Digest::MD5::File qw(dir_md5_hex file_md5_hex url_md5_hex);
use DBI();
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
use open IO => ":utf8",":std";
use utf8;
use Encode;
use Text::Unidecode;
#use misc;

my $version_dev="1.0.1utf8decode";
my $debug=1;
my $onsite_default=8;

$dbh = DBI->connect("DBI:mysql:ROMANES3:127.0.0.1",'root',undef,{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
#&sql_update($dbh,"SET NAMES utf8");


# Get command line parameter
my $out_dir=$ARGV[0];

# Opens Album.idx
if ($debug) {print STDERR "Opening album.idx\n";}
open(ALB,"$out_dir/album.idx")|| die "no album $out_dir/album.idx!\n";
my ($onsite,$onsite_thb,$onsite_img);
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
        if (/^classification_id/) {
            ($tmp,$classification)=split(/:/,$_); }
        if (/^creation/) {
            ($tmp,$creation_date)=split(/:/,$_); }
        if (/^title/) {
            ($tmp,$title)=split(/:/,$_); }
        if (/^url/) {
            ($tmp,$url)=split(/:/,$_); }
        if (/^order/) {
            ($tmp,$order)=split(/:/,$_); }
        if (/^map_url/) { ($tmp,$map_url)=split(/:/,$_)};
        if (/^map_img_low/) {($tmp,$map_img_low)=split(/:/,$_)};
        if (/^map_source_text/) {($tmp,$map_source_text)=split(/:/,$_)};
        if (/^map_source_url/) {($tmp,$map_source_url)=split(/:/,$_)};
        if (/^map_source_book_id/) {($tmp,$map_source_book_id)=split(/:/,$_)};
}
close(ALB);

$title=~s/\'/\\\'/g;
if ($display_order<1) {$display_order=1;}

# Opens photo.idx
if ($debug) {print STDERR "Opening photo.idx (main)\n";}
open(PHO,"$out_dir/photo.idx")||warn "no photo.idx!\n";
    while (<PHO>) {
	chomp;
	if (/^description/) {
        ($tmp,$description)=(/^(description):"(.*)"/); }
	if (/^map_url/) { ($tmp,$map_url)=split(/:/,$_)};
	if (/^map_img_low/) {($tmp,$map_img_low)=split(/:/,$_)};
	if (/^map_source_text/) {($tmp,$map_source_text)=split(/:/,$_)};
	if (/^map_source_url/) {($tmp,$map_source_url)=split(/:/,$_)};
	if (/^map_source_book_id/) {($tmp,$map_source_book_id)=split(/:/,$_)};
}
close(PHO);

$description=~s/\'/\\\'/g;
$description=~s/^"//;
$description=~s/"$//;
my $idx;

if ($description) {
	my $sql="SELECT MAX(id_l) from strings";
	if ($debug) { print STDERR $sql."\n";}
	$idx=&sql_get($dbh,$sql);
	$idx++;
	my $sql="INSERT INTO strings (id,id_l,lang,text) VALUES (null,$idx,\'fr\',\'$description\')";
	if ($debug) { print STDERR $sql."\n";}
	&sql_update($dbh,$sql);
}

if ($epoch) {
	$sql="INSERT INTO album (id,url,onsite,title,epoch,epoch_style,epoch_str,display_order,creation,comment_id) VALUES (null,\'$url\',$onsite_default,\'$title\',$epoch,\'$epoch_style\',\'$epoch_str\',$display_order,\'$creation_date\',$idx)";
} else {
	$sql="INSERT INTO album (id,url,onsite,title,display_order,creation,comment_id) VALUES (null,\'$url\',$onsite_default,\'$title\',$display_order,\'$creation_date\',$idx)";
}
if ($debug) { print STDERR $sql."\n";}
&sql_update($dbh,$sql);

my $sql="SELECT id FROM album WHERE title=\'$title\' AND url=\'$url\'";
if ($debug) { print STDERR $sql."\n";}
my $album_id = &sql_get($dbh,$sql);

my ($i2,$i3,$place_id)=&get_author_creation_place($out_dir);
$sql="INSERT INTO album_place (album_id,place_id) VALUES ($album_id,$place_id)";
if ($debug) { print STDERR $sql."\n";}
&sql_update($dbh,$sql);

#
# Classification
#
my @classification_id=split(/,/,$classification);
foreach $c_id (@classification_id) {
	my $sql="INSERT INTO album_classification (album_id,id_rel) VALUES ($album_id,$c_id)";
	if ($debug) { print STDERR $sql."\n";}
	&sql_update($dbh,$sql);
}

#
# Map
#
if ($map_img_low) {
	if ($debug) { print STDERR "Start MAP \n";}
        if (!$map_source_book) {$map_source_book=0;}

	my $sql = "INSERT INTO map (id,album_id,map_url,map_img_low,map_source_text,map_source_url,map_source_book_id) VALUES (null,$album_id,'$map_url','$map_img_low','$map_source_text','$map_source_url',$map_source_book_id);";
	if ($debug) { print STDERR $sql."\n";}
	&sql_update($dbh,$sql);

		my $sql="SELECT id from map where map_img_low='$map_img_low'";
		my $map_id=&sql_get($dbh,$sql);

		my $sql = "INSERT INTO map_album (map_id,album_id) VALUES ($map_id,$album_id);";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);
} else {
	if ($debug) { print STDERR "No MAP \n";}
}

#
# Books
#
if (-e "$out_dir/books.idx") {
	if ($debug) {print STDERR "Start Books\n";}
	open(FIC,"$out_dir/books.idx")||die"Error: images.idx: $!";;
	my $fic_cnt=1;
	while(<FIC>) {
		next if (/^#/);
		chomp;
		my $fic=$_;
		my $sql="INSERT INTO book_album (album_id,book_id) VALUES ($album_id,$fic)";
		if ($debug) { print STDERR $sql."\n";}
		&sql_update($dbh,$sql);
	}
	close(FIC);
	
} else {
	if ($debug) {print STDERR "No Books\n";}
}

#
# links.idx 
#
foreach $lang ('fr','en','es','de') {
    my $fl;
    # Set Lang format
    if ($lang eq 'fr') {
	if ((!(-e "$out_dir/links_fr.idx"))&&(-e "$out_dir/links.idx")) {
		$fl="links.idx";
	}
    } else {
	$fl="links_".$lang.".idx";
    }
    # Open file
    if ($debug) {print STDERR "testing $fl - ";}
    if (-e "$out_dir/$fl") {
	if ($debug) {print STDERR "Opening $fl\n";}
	open(FIC,"$out_dir/".$fl)||warn "$out_dir/$fl not found: $!";

	my $fic_cnt=1;my $text;my $alt_txt=1;
	while(<FIC>) {
		next if (/^#/);
		chomp;
		my $fic=$_;
		$fic=~s/\/$//;
		if ($alt_txt %2) {
			$text=$fic;
			$alt_txt++;
			next;
		}
		&link_insert($fic,$outdir,$fic_cnt++,$text,$lang);
		$alt_txt++;
	}
	close(FIC);
    } elsif ($debug) {print STDERR " none.\n";}
}

#
# images.idx 
#
open(FIC,"$out_dir/images.idx")||die"Error: images.idx: $!";;
<FIC>; <FIC>; <FIC>;
my $fic_cnt=1;
while(<FIC>) {
        next if (/^#/);
        chomp;
        my $fic=$_;
	&photo_insert($fic,$outdir,$fic_cnt++,$title);
}
close(FIC);


# Close DB connection
if ($debug) {print STDERR "Database disconnection\n";}
$dbh->disconnect;

print "Done\n";

exit;



sub photo_insert {
	my ($myfile,$outdir,$new_index,$album_name)=@_;
	if (!(-e "$out_dir/$myfile")) {next;}
	my $info = image_info("$out_dir/$myfile");
	my $width  = $info->{width};
	my $height = $info->{height};

	# else no change ?
    my $md5 = Digest::MD5->new;
    $md5->addpath("$out_dir/$myfile");
    my $digest = $md5->hexdigest;

    my $sql="select id from photo where md5='".$digest."'";
    #if ($debug) {print STDERR "$sql\n";}
    my $other_id=&sql_get($dbh,$sql);
	print STDERR "WARNING: $myfile already registered as $other_id\n" if ($other_id);


        if (($height<1)||($width<1)) {next;}

        if ($debug) {print STDERR "#Working on $myfile\n"};
		next if (/#/);

		if (!(-e "$out_dir/$myfile")) {
			print STDERR "Warning: $out_dir/$myfile doesn not exist ! \n";
			next;
		}
		$myfile=~s/\ /\\ /g;
		print "#Working on $myfile\n";

		# Insert Photo
		my $thumbfile="thb-".$myfile;
		$thumbfile=~tr/\ /_/;
		$album_name=~tr/'/\\'/;
		my ($i2,$i3,$i4)=&get_author_creation_place($out_dir);
		$i1=&generate_sernum($myfile,$i2,$i3,$i4,0);
	

		my $sql = "INSERT INTO photo (id,sernum,author_id,creation,place_id,resolution_x,resolution_y,description,original_file,thumb_file,name,site_img,site_thb,md5) VALUES (null,'$i1',$i2,'$i3',$i4,$height,$width,'','$myfile','$thumbfile','$album_name',$onsite_img,$onsite_thb,'$digest');";
		if ($debug) {print STDERR $sql."\n"};
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
	if ($debug) {print STDERR "Opening  $out_dir/photo.idx (sub)\n";}
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

sub link_insert {
	my ($myfile,$outdir,$new_index,$new_text,$lang)=@_;
	$new_text=~s/\'/\\\'/g;

	if (!($lang)){$lang='fr';}
	# Check wether link already exist elsewhere
	my $sql = "SELECT id from link where url='$myfile' order by id";
	if ($debug) {print STDERR $sql."\n"};
	my $link_id = &sql_get($dbh,$sql);
	
	if (! ($link_id)) {

		# Insert link
		my $sql = "INSERT INTO link (id,url,name,lang) VALUES (null,'$myfile','$new_text','$lang');";
		if ($debug) {print STDERR $sql."\n"};
		my $rc = &sql_update($dbh,$sql);

		# Get link id
		my $sql = "SELECT id from link where url='$myfile'";
		if ($debug) {print STDERR $sql."\n"};
		$link_id = &sql_get($dbh,$sql);
	}

	# Insert Link-Album relationship
	my $sql =  "INSERT INTO link_album (album_id,link_id,display_order,publish,lang) VALUES ($album_id,$link_id,$new_index,1,\'$lang\');";
	if ($debug) {print STDERR "$sql\n";}
	my $rc = &sql_update($dbh,$sql);
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

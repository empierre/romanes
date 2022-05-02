#!/usr/bin/perl
#
# Refresh the image list for an album
#
#
# version:0.99
#
use Image::Info qw(image_info);
use DBI();
#use misc;

#$debug=1;

my $dbh = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8mb4 => 1})  or die "Unable to connect to Database: ". $DBI::errst."\n";
&sql_update($dbh,"SET NAMES utf8mb4");

# Get command line parameter
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];

# Get the Album data
my $sql = "SELECT title FROM album where id=$album_id";
my $album_title=&sql_get($dbh,$sql);
print STDERR "Album $album_id: $album_title\n";


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
		my $sql	="select id from photo where original_file=\'".$fic."\'";
		if ($debug) {print STDERR "$sql\n";}
		my $photo_id=&sql_get($dbh,$sql);
		my ($i2,$i3,$i4)=&get_author_creation_place($out_dir);
		# Update sernum
		my $sql	="UPDATE photo SET sernum=\'".&generate_sernum($fic,$i2,$i3,$i4,$photo_id)."\' where id=$photo_id";
		if ($debug) {print STDERR "$sql\n";}
		&sql_update($dbh,$sql);
}
close(FIC);

# Close DB connection
if ($debug) {print STDERR "Database disconnection\n";}
$dbh->disconnect;

print "Done\n";


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

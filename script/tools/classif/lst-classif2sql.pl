#!/usr/bin/perl

use DBI();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES2",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";


open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($album_id,$album_name,$class_lst)=split(/;/);
	my (@classif)=split(/-/,$class_lst);


    next if (! $album_id);

	$sql = "select photo.id from photo,album_photo where album_photo.photo_id=photo.id and album_photo.album_id=$album_id";
	$sth = $dbh->prepare($sql);
	$sth->execute();

	my ($album_list,$palbum_list,$cnt,@tab_photo);
	$sth->bind_columns(\$palbum_list);

	while ($sth->fetch()) {
		if ($cnt<1) {
			$album_list=$palbum_list;
		} else {
			$album_list.=",$palbum_list";
		}
		push @tab_photo,$palbum_list;
	}
	$sth->finish();

	foreach $photo_id (@tab_photo) {
		foreach $id_rel (@classif) {
			my $out="INSERT INTO cross_classification (photo_id,id_rel) VALUES ($photo_id,$id_rel);\n";
			print $out;
		}
	}

	print $out;
	
};
close(FIC);

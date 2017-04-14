#!/usr/bin/perl
#
# Refresh the album data
#
#
# version:0.99
#
use Image::Info qw(image_info);
use DBI();
#use misc;

$debug=1;

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
# Links
#

#
# Reresh DB
#

#
# links.idx sync
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
    #if ($debug) {print STDERR "\nLang file is: $fl\n";}

	#Building ref data
	my %ref;my %ind;my %newind;my %newtxt;my %newlang;
	my $sql="select link_album.link_id,link_album.display_order,link.url from link_album,link where link_album.album_id=$album_id and link_album.link_id=link.id and link_album.lang=\'$lang\'";
	#if ($debug) {print STDERR "$sql\n";}
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	
	my ($i1,$i2,$i3);
	$sth->bind_columns(\$i1,\$i2,\$i3);
	
	while ($sth->fetch()) {
		$ref{$i3}=$i1;
		$ind{$i3}=$i2;
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
		next if (length($fic)<10);
		if (!$newind{$fic}) {
			if ($debug) {print STDERR "$fic $text $lang -> $fic_cnt\n";}
			$newind{$fic}=$fic_cnt++;
			$newtxt{$fic}=$text;
			$newlang{$fic}=$lang;
			$alt_txt++;
		} else {
			print "$fic is duplicate\n";
		}
	}
	close(FIC);
    } elsif ($debug) {print STDERR " none.\n";}

	foreach $key (keys %newind) {
	#if ($debug) { print "$key -> ".$ind{$key}."\n";}
	     if ($ind{$key} ne '') {
	     #Key exist
		if (!($newind{$key}==$ind{$key})) {
		# Order has changed
			print "$key#".$ref{$key}." update from ".$ind{$key}." to ".$newind{$key}."\n";
			my $sql="UPDATE link_album SET display_order=".$newind{$key}.",publish=1 WHERE link_id=" .$ref{$key};
			if ($debug) {print STDERR "$sql\n";}
			&sql_update($dbh,$sql);
		} # else no change
	     } else {
			#NEW 
			print "$key new at ".$newind{$key}."\n";
			&link_insert($key,$out_dir,$newind{$key},$newtxt{$key});
	     }
	}
	foreach $key (keys %ind) {
		if (!$newind{$key} ne '') {
			print "$key#".$ref{$key}." removed from ".$ind{$key}."\n";
			my $sql="UPDATE link_album SET display_order=0,publish=0 WHERE link_id=".$ref{$key}." AND album_id=$album_id";
			if ($debug) {print STDERR "$sql\n";}
			&sql_update($dbh,$sql);
		}
	}
}

# Close DB connection
if ($debug) {print STDERR "Database disconnection\n";}
$dbh->disconnect;

print "Done\n";



sub link_insert {
	my ($myfile,$outdir,$new_index,$new_text,$lang)=@_;
	$new_text=~s/\'/\\\'/g;
	$myfile=~s/\'/\\\'/g;

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
	my ($original_file) = @_;

	# S/R procedure
	($sr1,$seq1)=($original_file=~/-([A-Z0-9]+)\-([0-9]+)\.jpg$/);
}

1;

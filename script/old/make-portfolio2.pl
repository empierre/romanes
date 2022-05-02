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

#version
my $version_dev="0.99";
my $debug=1;

#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

#
# Command Line Options Analysis
#
my %opts;
getopt('a', \%opts);
if ($opts{'V'}) {
    print "ROMANES3 make-page v$version_dev\n";
    exit 64;
}
if ($opts{'d'}) {
	$debug=1;
    print STDERR "debug=on\n";
    exit 64;
}
if ($opts{'h'}) {
    &show_usage;
    exit 64;
}
#if (length($ARGV[0])<1) {
#    &show_usage;
#    exit 64;
#}

# Parameters
my $out_dir=$ARGV[0];
my $lang_param=$ARGV[1];

if (length($lang_param)==2) {
	$lang_param = "_".$lang_param;
} else {
	$lang_param='';
}

# Global data
my $t_header;
my $t_content;
my $t_footer;
#my $photo_dir="http://perso.orange.fr/e-nef/";
#my $photo_thumb_dir="http://perso.orange.fr/e-nef/";

#my $photo_wp800x600_dir="http://romanes.free.fr/wp-800x600/";
#my $photo_wp1024x768_dir="http://romanes2.free.fr/wp-1024x768/";

my %web_host_img=(
	"1" => "http://romanes.free.fr/",
	"2" => "http://romanes2.free.fr/",
	"3" => "http://romanes3.free.fr/",
	"4" => "http://romanes4.free.fr/"
);
my %web_host_thb=(
	"1" => "http://perso.orange.fr/e-nef/"
);
my %web_host_album=(
	"1" => ""
);

my $local_tmpl="/mnt/data/web/dev/romanes2.com/templates/";
my $photo_album_file="index.html";


# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");



my @album_list=(88,87,89,90);
#Get album list
my $item_per_line=2-1;
my $cnt=0;my $reg_cnt=0;
foreach my $album_id (@album_list) {
		#Get album data
		my $sql="SELECT photo.id,photo.thumb_file,photo.site_thb,album.url,album.title from photo,album_photo,album where album.id=$album_id and album.id=album_photo.album_id and album_photo.photo_id=photo.id and album_photo.display_order=1";
		#if ($debug) {print STDERR "$sql\n";}
		if ($debug) {print STDERR "id:$album_id\n";}
    	my $sth = $dbh->prepare($sql);
    	$sth->execute();
		$sth->bind_columns(\$p_id,\$p_thumb,\$p_site_thb,\$p_alb_url,\$p_alb_title);
		while ($sth->fetch()) {
			if ($cnt==0) {
            	my @loop2;
                $loop=\@loop2;
            }
			my %ix=();
            %ix=('thb_url'=>"http://perso.orange.fr/e-nef/thumb/$p_thumb",'place_name_fr'=>$p_alb_title,'album_url'=>$hosting.$p_alb_url,'BGC'=>'#E6E6D2');
            if ($debug) {print STDERR "cnt:$cnt\n";}
            if ($cnt>=$item_per_line) {
            	push  @{$loop},\%ix;
                if ($debug) {print STDERR "push 1 $v".\%ix." ".\@loop0." ".$loop."\n";}
                push @loop0,{'thb_site_loop_td'=>$loop};
                $cnt=0;$reg_cnt++;
			} else {
            	push @{$loop},\%ix;
                if ($debug) {print STDERR "push 2 $v\n";}
                $cnt++;
            }
		}
		$sth->finish();

}
if (($cnt<=$item_per_line)&&($cnt>0)) {
		my %ix=('thb_url'=>'/img/null.gif','place_name_fr'=>'','album_url'=>'','BGC'=>'#000000');
		push  @{$loop},\%ix;
		push @loop0,{'thb_site_loop_td'=>$loop};
		if ($debug) {print STDERR "push 3 $v".\%ix." ".\@loop0." ".$loop."\n";}
		$cnt=0;$reg_cnt++;
}
#
#Publish
#
my $t_content;
$t_content=HTML::Template->new(filename=>"$local_tmpl/pages/portfolio_list.tmpl.html",die_on_bad_params=>0);
$t_content->param('thb_site_loop_line',\@loop0);
print $t_content->output;

exit;


#
# Get the Album data
#
my $sql = "SELECT url,onsite,title,creation,comment_id FROM album where id=$album_id ORDER BY id";
my $sth = $dbh->prepare($sql);
$sth->execute();

my ($album_url,$album_title,$album_onsite,$album_creation,$comment_id,$album_comment);
my ($url,$title,$onsite,$commentid);
$sth->bind_columns(\$url,\$onsite,\$title,\$creation,\$commentid);

while ($sth->fetch()) {
	$album_url=$url;$album_onsite=$onsite;$album_title=$title;$album_creation=$creation;$comment_id=$commentid;
}
$sth->finish();

my $sql="SELECT text FROM strings where id_l=$comment_id";
if ($debug) {print STDERR $sql."\n";}
$album_comment=&sql_get($dbh,$sql);

#exit unless ($title);
print STDERR "Album name: $title\n";
print "$album_id:$out_dir:$lang_param:$title:";
my $titlestrip=$title;
$titlestrip=~s/\s/_/g;
$titlestrip=~s/\'/_/g;
$titlestrip=~tr/???????/eeeaaoo/;
if ($debug) {print STDERR "$titlestrip\n";}

# Album size
#
$sql = "SELECT count(id) from album";
my $sth = $dbh->prepare($sql);
$sth->execute();

my ($tsize,$psize);
$sth->bind_columns(\$psize);

while ($sth->fetch()) {
	$photo_nr=$psize;
}
$sth->finish();





$dbh->disconnect;
print STDERR "Done\n";
exit;


sub generate_index {
		if ($photo_nr<1) {
			print STDERR  "ok No index to generate\nexiting...\n";
			exit;
		}

		# Index page
		#
		$t_index=HTML::Template->new(filename=>"$local_tmpl/index.tmpl.html",die_on_bad_params=>0);

		# Get the Album List

		# Album size
		$sql = "SELECT count(id) from album";
		my $sth = $dbh->prepare($sql);
		$sth->execute();

		my ($tsize,$psize);
		$sth->bind_columns(\$psize);

		while ($sth->fetch()) {
			$tsize=$psize;
		}
		$sth->finish();

		# Make the Album list sorted by col
		#my $tab_l=int($tsize/3);
		#my $tab_mod1=$tsize%3;if ($tab_mod1>1) {$tab_mod1=1;}
		#my $tab_mod2=$tsize%3;
		#my $nbline=$tab_l+$tab_mod1;

		#$sql = "SELECT url,onsite,title FROM album ORDER BY title";
		#my $sth = $dbh->prepare($sql);
		#$sth->execute();

		#my ($url,$val,$onsite);
		#$sth->bind_columns(\$url,\$onsite,\$val);

		#my $cnt=1;my @tab_album_c;my (@tab1,@tab2,@tab3,@tab4);
		#while ($sth->fetch()) {
		#    	my %ix=('url'=>$url,'val'=>$val);

		#	    my $line=$cnt%$nbline;
		#		if ($line==0) {$line=$nbline;}
		#		push @{"tab".$line},\%ix;
		#		#print STDERR "T:$line:$val\n";

		#	$cnt++;
		#}
		#$sth->finish();

		#if ($tab_mod2>=1) {
		#	#print STDERR "ctrl:".(($cnt-1)%$nbline)."-".($cnt-1)."-$nbline\n";
		#	for ($i=(($cnt-1)%$nbline)+1;$i<=$nbline;$i++) {
		#		push @{"tab".$i},{url=>'',val=>''};
		#		#print STDERR "T:$i:compl L".$i."\n";
		#	}
		#};

		#Now list vignettes
		for ($i=1;$i<=$nbline;$i++) {
			push @loop1,{'CATL2'=>\@{"tab".$i}};	
		}
		$t_index->param('CATL1',\@loop1);


		# Images index
		$t_index->param('album_title',$album_title);
		$t_index->param('album_creation',$album_creation);

		my $sql="SELECT DISTINCT photo.id,photo.thumb_file,photo.site_img,photo.site_thb FROM photo,album_photo where photo.id=album_photo.photo_id AND album_id=$album_id and album_photo.publish=1  ORDER BY album_photo.display_order";

		my $sth = $dbh->prepare($sql);
		$sth->execute();

		my ($id,$tf,$cnt,@loop1,$loop,$site_img,$site_thb);
		$sth->bind_columns(\$id,\$tf,\$site_img,\$site_thb);


		my $photo_nr=1;
		while ($sth->fetch()) {
		if ($cnt==0) {
			my @loop2;
			$loop=\@loop2;
		}
		$tf=~s/\\//g; 
		my $photo_thumb_dir = $web_host_thb{$site_thb};
		my $photo_name_file_thb=$titlestrip."_".&pad_number($photo_nr)."$lang_param.html";
		$photo_name_file_thb=~tr/?????/ieeaa/;

		my %ix=('url'=>$photo_name_file_thb,'img'=>"$photo_thumb_dir/thumb/$tf");
		#print STDERR "$id-$tf\n";
		if ($cnt>=4) {
			push  @{$loop},\%ix;
			#print STDERR "push 1 $id ".\%ix." ".\@loop2." ".$loop."\n";
			push @loop1,{'loop2'=>$loop};	
			$cnt=0;
		} else {
			push @{$loop},\%ix;
			#print STDERR "push 2 $id\n";
			$cnt++;
		}
		$photo_nr++;
		}
		#print STDERR "test$cnt";
		if (($cnt<=4)&&($cnt>0)) {
		#print STDERR "test$cnt";
		push @loop1,{'loop2'=>$loop};	
		}
		$sth->finish();
		$t_index->param('loop1',\@loop1);

		# Menu liste
		foreach $fic ('lst_cister','lst_roman','lst_gothic','lst_medieval') {	
		open(F1,"$local_tmpl/$fic$lang_param.html")|| die "Error: $!\n";
		my $lst;
		while(<F1>) {
			$lst.=$_;
		}
		close(F1);
		$t_index->param("$fic",$lst);
		}

		# Site Map
		#
		if ($map) {
		$t_index->param('map',1);
		$t_index->param('map_url',$map_url);
		$t_index->param('map_img_low',$map_img_low);
		$t_index->param('map_source_text',$map_source_text);
		$t_index->param('map_source_url',$map_source_url);
		$t_index->param('map_source_book_id',$map_source_book_id);
		}

		# Other infos
		$t_index->param('photo_place',$place_name);
		$t_index->param('photo_city',$place_town);
		$t_index->param('photo_when',$creation);
		$t_index->param('photo_author',"$first_name $last_name");
		$t_index->param('photo_comment',$photo_description);

		#Sites proximit?
		$t_index->param('site_region_next',\@tab_site_region_next);
		$t_index->param('site_region_id',\@tab_site_region_id);



		# Save to file
		#print STDERR "Creating :".$out_dir."/".$photo_album_file."\n";
		open  FIC,">".$out_dir."/".$photo_album_file || die "Error: $!\n";
		print FIC $t_header->output;
		print FIC $t_index->output;
		print FIC $t_footer->output;
		close(FIC);
}



sub get_region() {
	my $album_id=shift(@_);
	# Get Local places
	#

	my $department=substr($postcode,0,2);my $region_id;
	if (($country==33)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	#if ($debug) {print STDERR "Lieu: $postcode-$department-$country-\n";}	

	if (($country==33)||($country==41)) {
		$department=substr($postcode,0,2);
		if (($country==33)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	}
		# Region name
		#
        if ($country==33) {

				$sql = "SELECT region_state.title,region.title,region.id FROM region,region_state where region.id=$department and region_state.id=region.region_id";
				$sth = $dbh->prepare($sql);
				$sth->execute();

				my ($pdepartment_name,$pregion_name,$pregion_id);
				$sth->bind_columns(\$pregion_name,\$pdepartment_name,\$pregion_id);

				while ($sth->fetch()) {
					$g_region_name=$pregion_name;
					$g_department_name=$pdepartment_name;
					$region_id=$pregion_id;
				}
				$sth->finish();
	    }
		return ($g_region_name,$region_id,$g_department_name);
}

sub show_usage {
    print "ROMANES3 make-page v$version_dev\n";
    print "Usage:\n";
    print "\tmake-page.pl [options] album_number destination_directory\n";
    print "\n";
    print "\tOptions:\n\n";
    print "\t-V\t\t\tPrint version\n";
    print "\t-d\t\t\tVerbose mode\n";
    print "\t-h\t\t\tPrint usage message\n";
    print "\n";
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

sub pad_number {
	my ($nr) = @_;
	my $res;
	if ($nr<10) { $res="000".$nr; }
	elsif ($nr<100) { $res="00".$nr; }
	elsif ($nr<1000) { $res="0".$nr; }
	return($res);	
}

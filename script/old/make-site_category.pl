#!/usr/bin/perl
#
# A revoir  27/08/09
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
#use strict;

#Updated for templates/pages/regions
#Filter per category
#2 | Roman                      
#3 | Gothique                    
#4 | Renaissance                  
#30 | Cistercien 
#35 | Ch?teau                     
#36 | Ch?teau fort                
#37 | Cit?e M?di?vale             

my $category_id=$ARGV[0];
if (! $category_id) {
  die "Please specify the category to produce !";
}

#select distinct album.id,album.title from album,album_classification,classification where album.id=album_classification.album_id and album_classification.id_rel=classification.id and classification.id=6 order by album.id;

# Make a list of site per regions

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");


my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";
my $debug=0;

#Generate site list
#
print STDERR "Generating France ".&get_category_by_id($category_id);
my $category_name=&get_category_by_id($category_id);

my $sql="select id,title from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@f_region,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
print STDERR ".";
while ($sth->fetch()) {
	push @f_region,$pid;
	$ptitle=~s/\'/\\\'/g;
	if (&get_albums_per_category_and_region($category_id,$pid)) {push @tab_menu,{'region_url'=>'#F'.$pid,'region_name_fr'=>$ptitle};}
	#print STDERR "$pid-$ptitle\n";
}
print STDERR ".";
&generate_region("$local_tmpl/pages/liste_site_fr.tmpl.html","France",$category_id,2,@f_region);
print STDERR ". ok\n";


#Generate per region page
#
while ($#tab_menu+1) {pop @tab_menu};
my $sql="select id,title from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@f_region,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
print STDERR ".";
push @tab_menu,{'region_url'=>'/France_'.$category_name.'_fr.html','region_name_fr'=>'France'};
while ($sth->fetch()) {
	push @f_region,$pid;
	$ptitle=~s/\s/_/g;
	$ptitle=~s/\'/_/g;
	$ptitle=~tr/???????/eeeaaoo/;
	if (&get_albums_per_category_and_region($category_id,$pid)) {push @tab_menu,{'region_url'=>"/".$ptitle."_".$category_name."_fr.html",'region_name_fr'=>$ptitle};}
}
my $sql="select id,title from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@t_region,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
while ($sth->fetch()) {
	my @l_region=($pid);
	#push @l_region,$pid;
	$ptitle=~s/\s/_/g;
	$ptitle=~s/\'/_/g;
	$ptitle=~tr/???????/eeeaaoo/;
	print STDERR "Generating $ptitle..";
	&generate_region("$local_tmpl/pages/region_fr.tmpl.html",$ptitle,$category_id,4,@l_region);
	print STDERR ". ok\n";
}

$dbh->disconnect;
print STDERR "Done\n";
exit;


sub generate_region {
		my $tmpl_name=shift(@_);
		my $region_name=shift(@_);
		my $category_id=shift(@_);
		my $item_per_line=shift(@_)-1;
		my @t_region;
		foreach (@_) { push @t_region,$_;}
		my $category_name=&get_category_by_id($category_id);
		if ($debug) {print STDERR "$tmpl_name-$region_name-$item_per_line-".join(':',@t_region)."\n";}

		my (%l_department);
		foreach my $dpt (@t_region) {
			my $sql="select id from region where region_id=$dpt";
			my $sth = $dbh->prepare($sql);
			$sth->execute();
			my ($pid,@t_department);
			$sth->bind_columns(\$pid);
			while ($sth->fetch()) {
				$l_department{$dpt}.="$pid,";
				#if ($debug) {print STDERR "reg:$pid\n";}
			}
		}


		my @tab_site_loop;my @site_loop;
		if ($debug) {print STDERR "tab_site_loop".join(':',@tab_site_loop)."\n";}
		#foreach (@tab_site_loop) { shift @tab_site_loop;}
		my $odd_even=0;my %tab={};my $cnt_s;
		foreach my $k (@t_region) {
			my @l=split(/,/,$l_department{$k});
			my $loop;my $cnt;my @loop1;my @loop0;my $reg_cnt;

			foreach my $v (@l) {

				my $sql="select photo.id,photo.place_id,photo.thumb_file,album.title,photo.resolution_x,photo.resolution_y,album.url,place.town,album.epoch_str,album.epoch_style from album_classification,classification,photo,place,album,album_photo where album.id=album_photo.album_id and album_photo.photo_id=photo.id and photo.place_id=place.id and place.postcode rlike '^$v' AND album_photo.publish=1 and album.id=album_classification.album_id and album_classification.id_rel=classification.id and classification.id=$category_id order by album_photo.display_order";
				my $sth = $dbh->prepare($sql);
				$sth->execute();
				my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str,$epoch_style,$px,$py,$town_name);
				my %mem_dep;
				$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$px,\$py,\$album_url,\$town_name,\$epoch_str,\$epoch_style);
				#if (!($sth->rows>0)) {return;}
				while ($sth->fetch()) {
					if ($cnt==0) {
						my @loop2;
						$loop=\@loop2;
					}

					if (!$mem_dep{$plid}) {
						#print "$k-$v-$pid-$plid-$px-$py-$purl\n";
						$tf=~s/\\//g;
						$nm=~s/dE/d\'E/g;
						#print STDERR "$k $nm<img src=\"http://perso.orange.fr/e-nef/thumb/$tf\"><br/>\n";
						my %ix=();
						%ix=('thb_url'=>"http://perso.orange.fr/e-nef/thumb/$tf",'place_name_fr'=>$nm,'album_url'=>$hosting.$album_url,'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str,'style'=>$epoch_style,'BGC'=>'#E6E6D2');
						if ($cnt>=$item_per_line) {
							push  @{$loop},\%ix;
							#print STDERR "push 1 $v".\%ix." ".\@loop0." ".$loop."\n";
							push @loop0,{'thb_site_loop_td'=>$loop};	
							$cnt=0;$reg_cnt++;$cnt_s++;
						} else {
							push @{$loop},\%ix;
							#print STDERR "push 2 $v\n";
							$cnt++;
						}
						$mem_dep{$plid}=1;
					}
				}
				#push @loop1,{'thb_site_loop_line'=>$loop0};
				#push @loop1,$loop0;
			}
			if (($cnt<=$item_per_line)&&($cnt>0)) {
				my %ix=('thb_url'=>'/img/null.gif','place_name_fr'=>'','album_url'=>'','town_name_fr_1'=>'','epoch'=>'','style'=>'','BGC'=>'#000000');
				push  @{$loop},\%ix;
				push @loop0,{'thb_site_loop_td'=>$loop};
				#print STDERR "push 3 $v".\%ix." ".\@loop0." ".$loop."\n";
				$cnt=0;$reg_cnt++;$cnt_s++;
			}
			#push @site_loop,{'title_name_fr'=>"France $k",'thb_site_loop_line'=>\@loop1};
			my $region_name=&get_region_by_id($k);
			push @site_loop,{'title_name_fr'=>"France -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
			#if ($region_name eq 'France') {push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};}
			#my @loop3;
			#$loop0=\@loop3;

		}
return unless $cnt_s; # Counter to see if album is void
		#POS
		my @POS_loop;
		push @POS_loop,{'url'=>'/France_'.$category_name.'_fr.html','name'=>'France'};

		#Include regional text
		my $region_intro;
		if (-e $local_tmpl."pages/regions/".$category_name."/".$region_name.".html") {
			open(REG,$local_tmpl."pages/regions/".$region_name.".html");
			while(<REG>) {
				$region_intro.=$_;
			}
		}

		#
		#Publish
		#
		my $t_content;
		$t_content=HTML::Template->new(filename=>$tmpl_name,die_on_bad_params=>0);
		$t_content->param('site_loop',\@site_loop);
		$t_content->param('region_list',\@tab_menu);
		$t_content->param('region_name_fr',"France");
		$t_content->param('region_intro',$region_intro);
		$t_content->param('marqueur',"Site_List_France");
		$t_content->param('POS_loop',\@POS_loop);

		open(FIC,">".$region_name."_".$category_name."_fr.html");
		print FIC $t_content->output;
		close(FIC);
		#foreach (@t_region) { shift @t_region;}
}


sub get_region_by_id($){
	my ($id)=shift;
	my $sql="select title from region_state where id=$id";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid);
	$sth->bind_columns(\$pid);
	while ($sth->fetch()) {
		$id=$pid;
	}

	return($id);
}

sub get_category_by_id($){
	my ($id)=shift;
	my $sql="select name from classification where id=$id";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid);
	$sth->bind_columns(\$pid);
	while ($sth->fetch()) {
		$id=$pid;
	}
	return($id);
}

sub get_albums_per_category_and_region($$){
	my ($category_id)=shift;
	my ($region_id)=shift;
	my $sql="select distinct album.id,album.title from album,album_classification,classification,album_place,place where album.id=album_classification.album_id and album_classification.id_rel=classification.id and classification.id=$category_id and album.id=album_place.album_id and album_place.place_id=place.id and place.region_id=$region_id order by album.id;";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	return($sth->rows);
}

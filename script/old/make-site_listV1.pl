#!/usr/bin/perl
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
#use strict;

#Updated for templates/pages/regions

# Make a list of site per regions

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";
my $debug=0;

#Generate site list
#
print STDERR "Generating France";
my $sql="select id,title from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@f_region,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
print STDERR ".";
while ($sth->fetch()) {
	push @f_region,$pid;
	$ptitle=~s/\'/\\\'/g;
	push @tab_menu,{'region_url'=>'#F'.$pid,'region_name_fr'=>$ptitle};
	#print STDERR "$pid-$ptitle\n";
}
print STDERR ".";
&generate_region("$local_tmpl/pages/liste_site_fr.tmpl.html","France",2,@f_region);
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
push @tab_menu,{'region_url'=>'/France_fr.html','region_name_fr'=>'France'};
while ($sth->fetch()) {
	push @f_region,$pid;
	$ptitle=~s/\s/_/g;
	$ptitle=~s/\'/_/g;
	$ptitle=~tr/éèêàâôö/eeeaaoo/;
	push @tab_menu,{'region_url'=>"/".$ptitle."_fr.html",'region_name_fr'=>$ptitle};
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
	$ptitle=~tr/éèêàâôö/eeeaaoo/;
	print STDERR "Generating $ptitle..";
	&generate_region("$local_tmpl/pages/region_fr.tmpl.html",$ptitle,4,@l_region);
	print STDERR ". ok\n";
}

$dbh->disconnect;
print STDERR "Done\n";
exit;


sub generate_region {
		my $tmpl_name=shift(@_);
		my $region_name=shift(@_);
		my $item_per_line=shift(@_)-1;
		my @t_region;
		foreach (@_) { push @t_region,$_;}
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
		my $odd_even=0;my %tab={};#my @tab_menu;
		foreach my $k (@t_region) {
			my @l=split(/,/,$l_department{$k});
			my $loop;my $cnt;my @loop1;my @loop0;my $reg_cnt;

			foreach my $v (@l) {

				my $sql="select photo.id,photo.place_id,photo.thumb_file,album.title,photo.resolution_x,photo.resolution_y,album.url,place.town,album.epoch_str,album.epoch_style from photo,place,album,album_photo where album.id=album_photo.album_id and album_photo.photo_id=photo.id and photo.place_id=place.id and place.postcode rlike '^$v' AND album_photo.publish=1 order by album_photo.display_order";
				my $sth = $dbh->prepare($sql);
				$sth->execute();
				my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str,$epoch_style,$px,$py,$town_name);
				my %mem_dep;
				$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$px,\$py,\$album_url,\$town_name,\$epoch_str,\$epoch_style);
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
							$cnt=0;$reg_cnt++;
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
				$cnt=0;$reg_cnt++;
			}
			#push @site_loop,{'title_name_fr'=>"France $k",'thb_site_loop_line'=>\@loop1};
			my $region_name=&get_region_by_id($k);
			push @site_loop,{'title_name_fr'=>"France -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
			#if ($region_name eq 'France') {push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};}
			#my @loop3;
			#$loop0=\@loop3;

		}

		#POS
		my @POS_loop;
		push @POS_loop,{'url'=>'/France_fr.html','name'=>'France'};

		#Include regional text
		my $region_intro;
		if (-e $local_tmpl."pages/regions/".$region_name.".html") {
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

		open(FIC,">".$region_name."_fr.html");
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

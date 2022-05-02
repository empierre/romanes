#!/usr/bin/perl
#
# $local_tmpl/pages/map_fr.tmpl.html
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;

# Gnerate a plan list per region

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";

my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";


my $sql="select id from region_state order by title";
my $sth = $dbh->prepare($sql);
$sth->execute();
my ($pid,@t_region);
$sth->bind_columns(\$pid);
while ($sth->fetch()) {
	push @t_region,$pid;
}

my (%l_department);
foreach my $dpt (@t_region) {
	my $sql="select id from region where region_id=$dpt";
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid,@t_department);
	$sth->bind_columns(\$pid);
	while ($sth->fetch()) {
		$l_department{$dpt}.="$pid,";
	}
}


my @tab_site_loop;
my $odd_even=0;my %tab={};
foreach my $k (@t_region) {
	my @l=split(/,/,$l_department{$k});
	my $loop;my $cnt;my @loop1;my $loop0;my @loop0;my $reg_cnt;

	foreach my $v (@l) {

###WORK
		my $sql="select map.place_id,map.map_img_low,place.town from map,place where map.album_id=album_place.album_id and album_place.album_id=album.id and album_place.place_id=place.id and place.postcode rlike '^$v' order by place.id";
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str);
		my %mem_dep;
		$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$album_url,\$town_name,\$epoch_str);
		while ($sth->fetch()) {
		}
###/WORK
		my $sql="select album.id,album_place.place_id,map.map_img_low,album.title,album.url,place.town,album.epoch_str from map,album,place,album_place where map.album_id=album_place.album_id and album_place.album_id=album.id and album_place.place_id=place.id and place.postcode rlike '^$v' order by place.id";
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str);
		my %mem_dep;
		$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$album_url,\$town_name,\$epoch_str);
		while ($sth->fetch()) {
			#next if (length($tf)<5);
			#print STDERR "$pid-$plid-$tf\n";
			if ($cnt==0) {
				my @loop2;
				$loop=\@loop2;
			}

			if (!$mem_dep{$plid}) {
				#print "$k-$v-$pid-$plid-$px-$py-$purl\n";
				$tf=~s/\\//g;
				$nm=~s/dE/d\'E/g;
				$nm=~s/dA/d\'A/g;
				#print STDERR "$k $nm<img src=\"$tf\"><br/>\n";
				my %ix=('thb_url'=>"$tf",'place_name_fr'=>$nm,'album_url'=>$hosting.$album_url,'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str);
				if ($cnt>=1) {
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
	if (($cnt<=1)&&($cnt>0)) {
		my %ix=('thb_url'=>'/img/null.gif');
        push  @{$loop},\%ix;
		push @loop0,{'thb_site_loop_td'=>$loop};
		#print STDERR "push 3 $v".\%ix." ".\@loop0." ".$loop."\n";
		$cnt=0;$reg_cnt++;
	}
	#push @site_loop,{'title_name_fr'=>"France $k",'thb_site_loop_line'=>\@loop1};
	my $region_name=&get_region_by_id($k);
	push @site_loop,{'title_name_fr'=>"France -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
	push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};
	#my @loop3;
	#$loop0=\@loop3;

}
#POS
my @POS_loop;
push @POS_loop,{'url'=>'/France_fr.html','name'=>'France'};


#
#Publish
#
my $t_content;
$t_content=HTML::Template->new(filename=>"$local_tmpl/pages/map_fr.tmpl.html",die_on_bad_params=>0);
$t_content->param('site_loop',\@site_loop);
$t_content->param('region_list',\@tab_menu);
$t_content->param('region_name_fr',"France");
$t_content->param('marqueur',"Map_List_France");
$t_content->param('POS_loop',\@POS_loop);
print $t_content->output;

$dbh->disconnect;
print STDERR "ok\n";
exit;


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

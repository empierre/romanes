﻿#!/usr/bin/perl
# (c) 2002-2017 Emmanuel PIERRE
#
# uses templates:
#	$local_tmpl/pages/liste_site_fr.tmpl.html
#	$local_tmpl/pages/region_fr.tmpl.html
#	$local_tmpl/pages/region/*.tmpl.html
#
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
use URI::Escape;
use Encode;
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
use open IO => ":utf8",":std";
use Encode;
use Text::Unidecode;
use Data::Dumper;
binmode(STDOUT, ":utf8");


#use strict;

#Updated for templates/pages/regions
# Make a list of site per regions

#version
my $version_dev="3.0.1";
my $debug=0;
my $regenerate=0;

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
    print "ROMANES3 make-site-list v$version_dev\n";
    exit 64;
}
if ($opts{'d'}) {
	$debug=1;
    print STDERR "debug=on\n";
#    exit 64;
}
if ($opts{'h'}) {
    &show_usage;
    exit 64;
}
if (length($ARGV[0])<1) {
    &show_usage;
    exit 64;
}

if ($opts{'s'}) {
	$regenerate=1;
}


#mysql> select count(distinct original_file) from photo;
#select count(*) from place;
#select count(distinct url) from link;

# Parameters
my $lang_param=$ARGV[0]||'';
my $lang_lst_param=$ARGV[1]||'';

if ($opts{'l'}) {
	if (!$lang_lst_param) {$lang_lst_param='fr';}
	my @lang_lst=split(/:/,$lang_lst_param);
	foreach $lang_show (@lang_lst) {
		if ($debug) {print STDERR "perl ./script/make-site_list.pl $lang_show $lang_lst_param\n";}
		`perl ./script/make-site_list.pl $lang_show $lang_lst_param`;
	}
	print STDERR "ok\n";
	exit 0;
}

if (length($lang_param)==2) {
	$lang_param = "_".$lang_param;
} else {
	$lang_param='';
}

# Global data
my $t_header;
my $t_content;
my $t_footer;

my $dbh = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8mb4 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";
my $dbh1 = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8mb4 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";
my $dbh2 = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8mb4 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";
&sql_update($dbh, "SET NAMES utf8");
&sql_update($dbh1,"SET NAMES utf8");
&sql_update($dbh2,"SET NAMES utf8");


my $local_tmpl='/mnt/data/web/prod/r2/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";


my %web_host_img=(
    "1" => "/media/",
    "2" => "/media/",
    "3" => "/media/",
    "4" => "/media/",
    "5" => "/media/",
    "6" => "/media/",
    "7" => "/media/",
    "8" => "/media/",
    "9" => "/media/",
    "10" => "/media/",
    "11" => "/media/",
    "12" => "/media/"
);
my %web_host_thb=(
	"1" => "/media/"
);
my %web_host_album=(
    "1" => "",
    "2" => "",
    "3" => "",
    "4" => "",
    "5" => "",
    "6" => "",
    "7" => "",
    "8" => "",
    "9" => "",
    "10" => "",
    "11" => "",
    "12" => ""
);

my $reference_onsite=8;


#Generate site list
#
# France
#
print STDERR "Generating $lang_param France ";
my $sql="select id,title from region_state where country=250 order by title";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_f,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
#print STDERR ".";
while ($sth->fetch()) {
	push @region_f,$pid;
	$ptitle=&get_region($pid,$lang_param,250);
	$ptitle=~s/\'/'/g;
	$ptitle=~s/_/ /g;
	#if ( $ptitle =~ /[\x80-\xff]/ ) {
	 	#$ptitle=decode_utf8($ptitle);
		#print STDERR "1 $pid-$ptitle\n";
	#}
	push @tab_menu_f,{'region_url'=>'#F'.$pid,"region_name_fr"=>$ptitle};
	#print STDERR "$pid-$ptitle\n";
}
#print STDERR ".";
&generate_region("$local_tmpl/pages/liste_site$lang_param.tmpl.html","France",250,2,250,\@region_f,\@tab_menu_f);
#print STDERR ". ok\n";

#
# Italy 
#
print STDERR "Generating $lang_param Italy  ";
my $sql="select id,title from region_state where country=380 order by id";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_i,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
while ($sth->fetch()) {
	push @region_i,$pid;
	$ptitle=&get_region($pid,$lang_param,380);
	$ptitle=~s/\'/'/g;
	$ptitle=~s/_/ /g;
	push @tab_menu_i,{'region_url'=>'#F'.$pid,"region_name_fr"=>$ptitle};
	#print STDERR "$pid-$ptitle\n";
}
#print STDERR ".";
&generate_region("$local_tmpl/pages/liste_site$lang_param.tmpl.html","Italie",380,2,380,\@region_i,\@tab_menu_i);

#
# France : Generate per region page
#
print STDERR "Generating $lang_param France regions";
while ($#tab_menu_f+1) {pop @tab_menu_f};
my $sql="select id,title from region_state where country=250 order by title";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_f,$ptitle,@tab_menu_f);
$sth->bind_columns(\$pid,\$ptitle);
push @tab_menu_f,{'region_url'=>"/France$lang_param.html",'region_name_fr'=>&get_country(250,$lang_param)};
while ($sth->fetch()) {
	push @region_f,$pid;
	$ptitle=&get_region($pid,$lang_param,250);
	my $phtitle=$ptitle;
	chomp($phtitle);
	$phtitle=~s/\s/_/g;
	$phtitle=~s/__/_/g;
	$phtitle=~s/\'/_/g;
	$phtitle=~s/_$//;
	$phtitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
	$phtitle=unac_string($phtitle);
	#print STDERR "tabmenuf $ptitle\n ";
	push @tab_menu_f,{'region_url'=>"/".$phtitle."$lang_param.html",'region_name_fr'=>$ptitle};
}	
my $sql="select id,title from region_state where country=250 order by title";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_f,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
while ($sth->fetch()) {
	my @region_f=($pid);
	$ptitle=&get_region($pid,$lang_param,250);
	$ptitle=~s/\s/_/g;
	$ptitle=~s/__/_/g;
	$ptitle=~s/\'/_/g;
	$ptitle=~s/_$//;
	$ptitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
	$ptitle=unac_string($ptitle);
	#print STDERR "regionf $ptitle ";
	&generate_region("$local_tmpl/pages/region$lang_param.tmpl.html",$ptitle,$pid,2,250,\@region_f,\@tab_menu_f);
	#print STDERR ". ok\n";
}
#
# Italie : Generate per region page
#
print STDERR "Generating $lang_param Italy regions";
while ($#tab_menu_i+1) {pop @tab_menu_i};
my $sql="select id,title from region_state where country=380 order by title";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_i,$ptitle,@tab_menu_i);
$sth->bind_columns(\$pid,\$ptitle);
push @tab_menu_i,{'region_url'=>"/Italie$lang_param.html",'region_name_fr'=>&get_country(380,$lang_param)};
while ($sth->fetch()) {
	push @region_i,$pid;
	$ptitle=&get_region($pid,$lang_param,380);
	   	my $phtitle=$ptitle;
		chomp($phtitle);
		$phtitle=~s/\s/_/g;
		$phtitle=~s/__/_/g;
		$phtitle=~s/\'/_/g;
		$phtitle=~s/_$//;
		$phtitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
		$phtitle=unac_string($phtitle);
		#print STDERR "tabmenui $ptitle ";
		push @tab_menu_i,{'region_url'=>"/".$phtitle."$lang_param.html",'region_name_fr'=>$ptitle};
}	
my $sql="select id,title from region_state where country=380 order by title";
my $sth = $dbh1->prepare($sql);
$sth->execute();
my ($pid,@region_i,$ptitle);
$sth->bind_columns(\$pid,\$ptitle);
while ($sth->fetch()) {
	my @region_i=($pid);
	#push @region_i,$pid;
	$ptitle=&get_region($pid,$lang_param,380);
	#$ptitle=encode("iso-8859-1",decode("utf8", $ptitle));
	#Encode::_utf8_off($ptitle);
	#$ptitle=decode_utf8($ptitle);
	#print STDERR "$ptitle ";
	$ptitle=~s/\s/_/g;
	$ptitle=~s/__/_/g;
	$ptitle=~s/\'/_/g;
	$ptitle=~s/_$//;
	$ptitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
	#$ptitle=unac_string("UTF-8",$ptitle);
	$ptitle=unac_string($ptitle);
	print STDERR "$ptitle ";
	&generate_region("$local_tmpl/pages/region$lang_param.tmpl.html",$ptitle,$pid,2,380,\@region_i,\@tab_menu_i);
	#print STDERR ". ok\n";
}

$dbh->disconnect;
$dbh1->disconnect;
$dbh2->disconnect;
print STDERR "Done\n";
exit;


sub generate_region {
		my $tmpl_name=shift(@_);
		my $region_name=shift(@_);	
		my $region_id=shift(@_);		
		my $item_per_line=shift(@_);
		my $country=shift(@_);
		my @t_region=@{$_[0]};
		my @tab_menu=@{$_[1]};

		if ($debug) {print STDERR "$tmpl_name-$region_name-$item_per_line-".join(':',@t_region)."\n";}

		#Get department in region
		my (%l_department);
		foreach my $dpt (@t_region) {
			my $sql="select id from region where region_id=$dpt and country=$country";
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
		#if ($debug) {print STDERR "tab_site_loop".join(':',@tab_site_loop)."\n";}
		my $odd_even=0;my %tab={};
		foreach my $k (@t_region) {
			my @l=split(/,/,$l_department{$k});
			my $loop;my $cnt;my @loop1;my @loop0;my $reg_cnt;

			foreach my $v (@l) {

				my $sql="select photo.id,photo.place_id,photo.thumb_file,photo.site_img,album.title,photo.resolution_x,photo.resolution_y,album.url,place.town,album.epoch_str,album.epoch_style,album.onsite from photo,place,album,album_photo where album.id=album_photo.album_id and album_photo.photo_id=photo.id and photo.place_id=place.id and place.postcode rlike '^$v' AND album_photo.publish=1 and place.country=$country order by album_photo.display_order";
				print $sql."\n";
				my $sth = $dbh->prepare($sql);
				$sth->execute();
				my ($pid,$plid,$nm,$tf,$si,$rx,$ry,$album_url,$place_name,$epoch_str,$epoch_style,$px,$py,$town_name,$album_onsite);
				my %mem_dep;
				$sth->bind_columns(\$pid,\$plid,\$tf,\$si,\$nm,\$px,\$py,\$album_url,\$town_name,\$epoch_str,\$epoch_style,\$album_onsite);
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
						my $lp=$lang_param;if ($lp eq '_fr') {$lp='';}
						my $thb=$tf;$thb=~s/^thb-//;
						$thb=$web_host_img{$si}.$thb;
						%ix=('thb_url'=>$thb,'place_name_fr'=>$nm,'album_url'=>$web_host_album{$album_onsite}.$album_url."/index$lp.html",'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str,'style'=>$epoch_style,'BGC'=>'#E6E6D2');
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
			my $region_name=&get_region($k,$lang_param,$country);
			$region_name=~s/_/ /g;
			my $country_name=&get_country($country,$lang_param);
			push @site_loop,{'title_name_fr'=>"$country_name -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
			#if ($region_name eq 'France') {push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};}
			#my @loop3;
			#$loop0=\@loop3;

		}

	#
	# Header
	#

		$t_header=HTML::Template->new(filename=>"$local_tmpl/header$lang_param.tmpl.html",die_on_bad_params=>1,utf8     => 1);
		if ($lang_param eq '_en') {
				$t_header->param('doc_title',"Romanes.com: Romanesque Art and Architecture, $region_name");
				$t_header->param('doc_description',"$region_name");
				$photo_keywords="romanesque, art, architecture, gothic, church, abbey, cathedral, cistercian, medieval, middle-age, patrimoiny, sculpture";
		} elsif ($lang_param eq '_es') {
				$t_header->param('doc_title',"Romanes.com: Romanica, G&oacute;tico Arte y Arquitectura, $region_name");
				$t_header->param('doc_description',"$region_name");
				$photo_keywords= "romanico, arte, architectura, gothico, iglesia, monasterio, catedral, cistercian, medieval, esculptura";
		} else {
				$t_header->param('doc_title',"Romanes.com: Art et Architecture Romane, $region_name");
				$t_header->param('doc_description',"$region_name");
		}
		$t_header->param('doc_keywords',$photo_keywords);


	# Europe / France / Ile de France / Etampes / Notre Dame du Fort

	#POS
	my $ncountry;
	my @POS_loop;
	$g_region_name=$region_name;
		
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/France'.$lang_param.'.html','name'=>'Europa'};
	if ($country==250) {$ncountry=&get_country($country,$lang_param);}
	if ($country==756) {$ncountry=&get_country($country,$lang_param);}
	if ($country==850) {$ncountry=&get_country($country,$lang_param);}
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.&get_country($country,'fr').$lang_param.'.html','name'=>$ncountry};

	#if ($region_name ne &get_country($country,$lang_param)) 
	if ($region_id) {
	  #if ($country==250) {
		my $ptitle=$g_region_name;
		chomp($ptitle);
		$ptitle=~s/\s/_/g;
		$ptitle=~s/__/_/g;
		$ptitle=~s/\'/_/g;
		$ptitle=~s/_$//;
		#$ptitle=~tr/éèêëàâôöùñóí_/eeeeaaoounoi /;
        	$ptitle=~tr/_/ /;
		#$ptitle=decode_utf8($ptitle);
		$ptitle=unac_string($ptitle);
		push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.$g_region_name.($lang_param||'_fr').'.html#','name'=>$ptitle};		  
	}
	if ($debug) {print STDERR "POS: $album_id $place_town $place_name\n";}
	$t_header->param('POS_loop',\@POS_loop);
	
	#
	# Footer
	#
		$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer$lang_param.tmpl.html",die_on_bad_params=>0,utf8     => 1);
        	my $marqueur=$album_title;
		$marqueur=~s/\s/_/g;
		$marqueur=~s/\'/_/g;
		$t_footer->param('marqueur',$marqueur);
		$t_footer->param('version_dev',$version_dev);

		#Include regional text
		my $region_intro;
		my $r_l=&get_region($region_id,'fr',$country);$r_l=~tr/ 'éè/__ee/;
	print STDERR "R: $_l ". $local_tmpl."pages/regions/".$r_l."$lang_param.html". "\n";
        	if ($debug) {print STDERR "template region ".$r_l."$lang_param.html\n";}
		if (($region_name eq 'Centre')||($region_name =~/Picardie/)) {
		    if (-e $local_tmpl."pages/regions/Ile_de_France$lang_param.html") {
			open(REG,$local_tmpl."pages/regions/Ile_de_France$lang_param.html");
			while(<REG>) { $region_intro.=$_; }
			close(REG);
		  }
		} elsif (-e $local_tmpl."pages/regions/".$r_l."$lang_param.html") {
			open(REG,$local_tmpl."pages/regions/".$r_l."$lang_param.html")||warn "$!";
			while(<REG>) { $region_intro.=$_; }
			close(REG);
		}

		#
		#Publish
		#
		my $t_content;
		$t_content=HTML::Template->new(filename=>$tmpl_name,die_on_bad_params=>0,utf8 => 1,loop_context_vars =>1);

		# language flags
		my @lang_lst=split(/:/,$lang_lst_param);
        if ($debug) {print STDERR "$lang_lst_param:$file_out ";}
        foreach $lang_show (@lang_lst) {
            if ($debug) {print STDERR "$lang_show";}
            $lang_show=lc($lang_show);
            $fo_lang=$photo_name_file;
            	$fo_lang=~s/out/$lang_show/;
		my $ptitle=&get_region($region_id,$lang_show,$country);
		$ptitle=~s/\s/_/g;
		$ptitle=~s/__/_/g;
		$ptitle=~s/\'/_/g;
		$ptitle=~s/_$//;
		$ptitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
		#$ptitle=decode_utf8($ptitle);
		$ptitle=unac_string($ptitle);
		$t_content->param("doc_local_$lang_show",$ptitle.'_'.$lang_show.".html");
            	$t_content->param("lang_$lang_show","/".$fo_lang);
		if ($debug) {print STDERR "lang_$lang_show->$fo_lang\n ";}
        }
	
		$ptitle=~s/_/ /g;
	        $ptitle=&get_region($region_id,$lang_param,$country);
		$t_content->param('region_name_fr',$ptitle);
		$t_content->param('site_region',$region_name);
		$t_content->param('site_loop',\@site_loop);
		$t_content->param('region_list',\@tab_menu);
		$t_content->param('region_intro',$region_intro);
		$t_content->param('region_name_categ_fr',$region_name);
		#my $rn_esc=uri_escape($rn{&get_region($region_id,"fr")},$country);
		my $rn_esc=&get_region($region_id,"fr",$country);
		$rn_esc=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
		#$rn_esc=decode_utf8($rn_esc);
		$rn_esc=unac_string($rn_esc);
		$rn_esc=~tr/ '/__/;
		$t_content->param('rss_region_fr',$rn_esc);
		#print STDERR 'rss_region_fr'.'='.$rn_esc."\n";

		#$region_name=~tr/éèêëàâôöùñóí '/eeeeaaoounoi__/;
        	$region_name=~tr/ '/__/;
		#$region_name=decode_utf8($region_name);
		$region_name=unac_string($region_name);
		open(FIC,">".$region_name."$lang_param.html")|| warn "ERR:$region_name $!\n";
		#print FIC $t_header->output;
		print FIC $t_content->output;
		#print FIC $t_footer->output;
		close(FIC);
}


sub get_country() {
	my $country_id=shift(@_);
	my $lang_id=shift(@_);
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='name';}
	my $sql = "SELECT country.".$lang_id." FROM country where country.id=$country_id";
	my $sth = $dbh2->prepare($sql);
	$sth->execute();


	my ($pstring);
	$sth->bind_columns(\$pstring);
	while ($sth->fetch()) {
		$cstring=$pstring;
	}
	$sth->finish();
	#$cstring=encode("iso-8859-1",decode("utf8", $cstring));
	chomp($cstring);
	return ($cstring);
}

sub get_region() {
	my $region_id=shift(@_);
	my $lang_id=shift(@_);
	my $country=shift(@_)||250;
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='title';}
	my $sql = "SELECT region_state.".$lang_id." FROM region_state where region_state.id=$region_id and country=$country";
	my $sth = $dbh2->prepare($sql);
	$sth->execute();

	my ($pstring);
	$sth->bind_columns(\$pstring);
	while ($sth->fetch()) {
		$cstring=$pstring;
	}
	$sth->finish();
	chomp($cstring);
	$cstring=~s/ $//;
	#$cstring=encode("iso-8859-1",decode("utf8", $cstring));	
	#$cstring=decode_utf8($cstring);
	#print STDERR "get_region $sql\n";
	return ($cstring);
}

sub sql_update {
	my ($dbh,$sql) = @_;
	my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
	return($rc);
}

sub show_usage {
    print "ROMANES3 make-site_list v$version_dev\n";
    print "Usage:\n";
    print "\tmake-site_list.pl [options] generation_language language_list:\n";
    print "\n";
    print "\tOptions:\n\n";
    print "\t-V\t\t\tPrint version\n";
    print "\t-d\t\t\tVerbose mode\n";
    print "\t-h\t\t\tPrint usage message\n";
    print "\t-l\t\t\tMultilinguism generation\n";
    print "\n";
}

#!/usr/bin/perl 
#
# (c) 2002-2018 Emmanuel PIERRE
#          epierre@romanes.com
#          http://www.e-nef.com/users/epierre
#
#$local_tmpl/header$lang_param.tmpl.html
#$local_tmpl/footer$lang_param.tmpl.html
#$local_tmpl/page_detail$lang_param.tmpl.html
#$local_tmpl/index$lang_param.tmpl.html
# 'lst_cister','lst_roman','lst_gothic','lst_medieval

#use strict;
use DBI();
#2.10.1 seulement !!!
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
use Encode;
use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
use open IO => ":utf8",":std";
use utf8;
use Encode;
use Text::Unidecode;

#version
my $version_dev="3.0.2";
my $debug=0;
my $regenerate=0;
my $relocation_path;

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
#Nearby sites regenerate
	$regenerate=1;
}

# Parameters
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];
my $lang_param=$ARGV[2]||'';
my $lang_lst_param=$ARGV[3]||'';

if ($opts{'l'}) {
	if (!$lang_lst_param) {$lang_lst_param='fr';}
	my @lang_lst=split(/:/,$lang_lst_param);
	foreach $lang_show (@lang_lst) {
		if ($debug) {print STDERR "./script/make-album.pl $album_id $out_dir $lang_show $lang_lst_param\n";}
		`perl ./script/make-album.pl $album_id $out_dir $lang_show $lang_lst_param`;
	}
	print STDERR " ok\n";
	exit 0;
}
#mysql> select count(distinct original_file) from photo;
#select count(*) from place;
#select count(distinct url) from link;

if (length($lang_param)==2) {
	$lang_param = "_".$lang_param;
} else {
	$lang_param='';
}
if (lc($lang_param) eq '_fr') { 
  #Default naming for french
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
    "1" => "/media",
    "2" => "/media",
    "3" => "/media",
    "4" => "/media",
    "5" => "/media",
    "6" => "/media",
    "7" => "/media",
    "8" => "/media",
    "9" => "/media",
    "10" => "/media",
    "11" => "/media",
    "12" => "/media"
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

my $local_tmpl="/mnt/data/web/prod/r2/templates/";
my $photo_album_file="index$lang_param.html";

my @tab_site_region_next=();
my @tab_site_region_id=();

# DB Connection
my $dbh = DBI->connect('DBI:mysql:ROMANES3;localhost','r2','romanes',{mysql_enable_utf8 => 1})  or die "Unable to connect to Contacts Database: ". $DBI::errst."\n";
#
#
# Get the Album data
#
my $sql = "SELECT url,onsite,title,creation,comment_id FROM album where id=$album_id ORDER BY id";
if ($debug) {print STDERR $sql."\n";}
my $sth = $dbh->prepare($sql);
$sth->execute();

my ($album_url,$album_title,$album_onsite,$album_creation,$comment_id,$album_comment);
my ($url,$title,$onsite,$commentid);
$sth->bind_columns(\$url,\$onsite,\$title,\$creation,\$commentid);

while ($sth->fetch()) {
	$album_url=$url;$album_onsite=$onsite;$album_title=$title;$album_creation=$creation;$comment_id=$commentid;
}
$sth->finish();

if ($album_onsite!=8) {
#  $relocation_path='/mnt/data/prod/romanes.org/';
}

my $sql="SELECT text FROM strings where id_l=$comment_id";
if ($debug) {print STDERR $sql."\n";}
$album_comment=&sql_get($dbh,$sql);


#exit unless ($title);
if (! $lang_param) {print STDERR "Album name: $title ";}
print "$album_id:$out_dir:$lang_param:$title:";
my $titlestrip=$title;
$titlestrip=~s/\s/_/g;
$titlestrip=~s/\'/_/g;
$titlestrip=unidecode($titlestrip);
if ($debug) {print STDERR "$titlestrip\n";}

# Postcode
#
$sql = "SELECT DISTINCT place.postcode,place.country FROM place,photo,album_photo where photo.place_id=place.id and album_photo.photo_id=photo.id and album_photo.album_id=$album_id";
if ($debug) { print STDERR $sql."\n";}
$sth = $dbh->prepare($sql);
$sth->execute();

my @tab_photo;
my ($postcode,$country,$ppostcode,$pcountry);
$sth->bind_columns(\$ppostcode,\$pcountry);

while ($sth->fetch()) {
    $postcode=$ppostcode;
    $country=$pcountry;
}
$sth->finish();

if (! $lang_param) {
	print STDERR "- generating pages ".($lang_param||'_fr');
} else {
	print STDERR ($lang_param||'_fr');
}

		# Get Local places
		#

		my $department=substr($postcode,0,2);
		if (($country==250)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
		if ($debug) {print STDERR "Local places:$postcode-$department-$country-\n"};	

		if (($country==250)||($country==756)) {
				my $department=substr($postcode,0,2);
				if (($country==750)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	
				# Same region sites
				#
				my $sql = "SELECT distinct album.id,album.url,place.name,album.onsite from photo,album_photo,album,place where photo.place_id=place.id and place.postcode rlike '^$department' and album_photo.photo_id=photo.id and album.id=album_photo.album_id";
				if ($debug) {print $sql."\n";}
				my $sth = $dbh->prepare($sql);
				$sth->execute();

				my ($site_same_dept_count,$generate_albums);
				my ($arg1,$arg2,$arg3,$arg4);
				$sth->bind_columns(\$arg1,\$arg2,\$arg3,\$arg4);

				while ($sth->fetch()) {
					$site_same_dept_count++;
					my $ar=$web_host_album{$arg4}.$arg2."/index$lang_param.html";
					my %tab=('site_url'=>$ar,'site_title'=>$arg3);
					push @tab_site_region_id,\%tab if (length($arg2)>3);
					$generate_albums.=$arg1.',';
				}
				$sth->finish();

				# Near Region Sites	
				#
				$sql = "SELECT list from region_proxy where id='$department'";
				if ($debug) {print STDERR "$sql\n"};
				$sth = $dbh->prepare($sql);
				$sth->execute();
				my (@department_list,$pdepartment_list);
				$sth->bind_columns(\$pdepartment_list);
				while ($sth->fetch()) {
					@department_list=split(/,/,$pdepartment_list);
				}
				$sth->finish();

				my ($query,$query_cnt);
				foreach $department_proxy (@department_list) {

						if ($department_proxy<10) {$department_proxy="0".$department_proxy;}

						my $sql = "SELECT distinct album.id,album.url,place.name,album.onsite from photo,album_photo,album,place  where photo.place_id=place.id and place.postcode rlike '^$department_proxy' and album_photo.photo_id=photo.id and album.id=album_photo.album_id";
						if ($debug) {print $sql."\n";}
						my $sth = $dbh->prepare($sql);
						$sth->execute();

						my ($site_next_dept_count);
						my ($arg1,$arg2,$arg3,$arg4);
						my @tab_site_region_next_local;
						my $site_next_dept_count;

						$sth->bind_columns(\$arg1,\$arg2,\$arg3,\$arg4);
						
						while ($sth->fetch()) {
							$site_next_dept_count++;
							my $ar=$web_host_album{$arg4}.$arg2."/index$lang_param.html";
							#my %tab=('site_url'=>$ar,'site_title'=>$arg3);
							my %tab=('site_url'=>$ar,'site_title'=>$arg3);
							push @tab_site_region_next_local,\%tab  if (length($arg2)>3);
							$generate_albums.=$arg1.',';

						}
						$sth->finish();

						# Region name
						#
						$sql = "SELECT title FROM region where id=$department_proxy";
						if ($debug) {print $sql."\n"}
						$sth = $dbh->prepare($sql);
						$sth->execute();

						my ($region_name,$pregion_name);
						$sth->bind_columns(\$pregion_name);

						while ($sth->fetch()) {
							$region_name=$pregion_name;
						}
						$sth->finish();

						
						# Put it all together
						#
						my %tab=('site_region_next_name'=>$region_name,'site_region_next_loop'=>\@tab_site_region_next_local);
						push @tab_site_region_next,\%tab if ($site_next_dept_count >1);

						if ($regenerate) {
								$generate_albums=~s/,$//;
								if (!$lang_lst_param) {$lang_lst_param='fr';}
								my @lang_lst=split(/:/,$lang_lst_param);
								foreach $lang_show (@lang_lst) {
								    if ($debug) {print STDERR "$lang_lst_param:$file_out:$lang_show ";}								    
									print "./script/make-albums.pl $generate_albums $lang_show $lang_lst_param\n";
									if ($generate_albums) {
										`/usr/bin/perl ./script/make-albums.pl $generate_albums $lang_show $lang_lst_param`;
									}
							}
							$generate_albums='';
						}
				}
		}

		# Site Map
		#
		my $sql="SELECT map.map_url,map.map_img_low,map.map_source_text,map.map_source_url,map.map_source_book_id,map.map_img_site FROM map,map_album where  map.id=map_album.map_id and map_album.album_id=$album_id";
		if ($debug) {print STDERR "$sql\n";}

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my ($umap_url,$umap_img_low,$umap_source_text,$umap_source_url,$umap_source_book_id,$umap_img_site);
        my ($map_url,$map_img_low,$map_source_text,$map_source_url,$map_source_book_id,$map_img_site);
        $sth->bind_columns(\$umap_url,\$umap_img_low,\$umap_source_text,\$umap_source_url,\$umap_source_book_id,\$umap_img_site);

        while ($sth->fetch()) {

			if ($umap_img_low) {
				$map=1;
				$map_url=$web_host_img{$umap_img_site}.$umap_url;
				$map_img_low=$web_host_img{$umap_img_site}.$umap_img_low;
				$map_source_text=$umap_source_text;
				$map_source_url=$umap_source_url;
				$map_source_book_id=$umap_source_book_id;
			}
		}


#
# Generate details page
#
$sql = "SELECT photo_id FROM album_photo where album_id=$album_id AND publish=1 LIMIT 1";
if ($debug) {print STDERR $sql."\n";}
$sth = $dbh->prepare($sql);
$sth->execute();

my @tab_photo;my $photo_id;
my ($photo);
$sth->bind_columns(\$photo);

while ($sth->fetch()) {
        $photo_id=$photo;
}
$sth->finish();

my $photo_name_file;my $photo_name_toprint_file;my $photo_nr=1;

		# Photo name
		$titlestrip=~s/éèâï/eeai/g;
		$photo_name_file=$titlestrip.$lang_param.".html";
		$photo_name_file=unidecode($photo_name_file);
		$photo_name_file_head=$titlestrip."_".&pad_number($photo_nr);
		$photo_name_file_head=unidecode($photo_name_file_head);
		$photo_album_file="index$lang_param.html";

		#
		# Header
		#

		# Get Photo Info
		#
		my $sql="SELECT author.first_name,author.last_name,author.email,author.show_email,author.url,photo.creation,place.name,place.town,place.country,place.postcode,photo.thumb_file,photo.name,photo.description,photo.site_img,photo.site_thb,photo.sernum FROM photo,author,place where photo.id=$photo_id AND photo.author_id=author.id AND photo.place_id=place.id";
		if ($debug) {print STDERR "$sql\n";}
		my $sth = $dbh->prepare($sql);
		$sth->execute();

		my ($first_name,$last_name,$email,$show_email,$url,$creation,$name,$town,$country,$postcode,$thumb_file,$photo_name,$photo_description,$site_img,$site_thb,$photo_ref);
		my ($pfirst_name,$plast_name,$pemail,$pshow_email,$purl,$pcreation,$pname,$ptown,$pcountry,$ppostcode,$pthumb_file,$pphoto_name,$pphoto_description,$ssite_img,$ssite_thb,$sphoto_ref);
		$sth->bind_columns(\$pfirst_name,\$plast_name,\$pemail,\$pshow_email,\$purl,\$pcreation,\$pname,\$ptown,\$pcountry,\$ppostcode,\$pthumb_file,\$pphoto_name,\$pphoto_description,\$ssite_img,\$ssite_thb,\$sphoto_ref);

		while ($sth->fetch()) {
			$first_name=$pfirst_name;
			$last_name=$plast_name;
			$email=$pemail;
			$show_email=$pshow_email;
			$url=$purl;
			$creation=$pcreation;
			$place_name=$pname;
			$place_town=$ptown;
			$country=$pcountry;
			$postcode=$ppostcode;
			$thumb_file=$pthumb_file;
			$photo_name=$pphoto_name;
			$photo_description=$pphoto_description;
			$site_img=$ssite_img;
			$site_thb=$ssite_thb;
			$photo_ref=$sphoto_ref;
		}
		$sth->finish();
#if ($debug) {print STDERR "$place_name $place_town\n";}


		# Get Keywords
		#
		$sql = "SELECT classification.name from cross_classification,classification where cross_classification.photo_id=$photo_id AND cross_classification.id_rel=classification.id";
		if ($debug) {print $sql."\n"}
		$sth = $dbh->prepare($sql);
		$sth->execute();
		
		my ($pkeywords,$photo_keywords);
		$photo_keywords="$place_name, $place_town, ";
		$sth->bind_columns(\$pkeywords);
		while ($sth->fetch()) {
			$photo_keywords.=$pkeywords.", ";
		}
		$sth->finish();

		$t_header=HTML::Template->new(filename=>"$local_tmpl/header$lang_param.tmpl.html",die_on_bad_params=>1, utf8=>1);
		if ($lang_param eq '_en') {
				$t_header->param('doc_title',"$photo_name by $first_name $last_name");
				$t_header->param('doc_description',"$photo_name of $place_town by $first_name $last_name");
				$photo_keywords="romanesque, art, architecture, gothic, church, abbey, cathedral, cistercian, medieval, middle-age, patrimoiny, sculpture";
		} elsif ($lang_param eq '_es') {
				$t_header->param('doc_title',"$photo_name por $first_name $last_name");
				$t_header->param('doc_description',"$photo_name de $place_town por $first_name $last_name");
				$photo_keywords= "romanico, arte, architectura, gothico, iglesia, monasterio, catedral, cistercian, medieval, esculptura";
		} elsif ($lang_param eq '_it') {
				$t_header->param('doc_title',"$photo_name por $first_name $last_name");
				$t_header->param('doc_description',"$photo_name por $place_town por $first_name $last_name");
				$photo_keywords= "roman, art, architecture, gothique, chiesa, Abbazia, cathédrale, cisterciense, cisterciensene, medioevale, moyen-age, romanica, patrimoine, scultura, romanicas, romanicasque";
		} else {
				$t_header->param('doc_title',"$place_name de $place_town par $first_name $last_name");
				$t_header->param('doc_description',"$place_name de $place_town par $first_name $last_name");
		}
		$t_header->param('doc_keywords',$photo_keywords);

	# Europe / France / Ile de France / Etampes / Notre Dame du Fort

	#POS body 
	my $ncountry;
	my @POS_loop;
	($g_region_name,$region_id,$g_department_name)=&get_region($album_id,$lang_param);
	
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/France'.($lang_param||'_fr').'.html','name'=>'Europa'};
	if ($country==250) {$ncountry=&get_country($country,$lang_param);}
	if ($country==756) {$ncountry=&get_country($country,$lang_param);}
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.&get_country($country,'').($lang_param||'_fr').'.html','name'=>$ncountry};
	if ($country==250) {
		my $ptitle=$g_region_name;
		chomp($ptitle);
		$ptitle=~s/\s/_/g;
		$ptitle=~s/__/_/g;
		$ptitle=~s/\'/_/g;
		$ptitle=~s/_$//;
		$ptitle=~s/éèâï/eeai/g;
		$ptitle=unidecode($ptitle);
		push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.$ptitle.($lang_param||'_fr').'.html#','name'=>$g_region_name};
		push @POS_loop,{'url'=>'index'.$lang_param.'.html','name'=>$place_town};
	} else {
		push @POS_loop,{'url'=>'/'.$ncountry.$lang_param.'.html','name'=>$place_town};
	}
	push @POS_loop,{'url'=>'index'.$lang_param.'.html','name'=>$place_name};
	if ($debug) {print STDERR "POS: $album_id $place_town $place_name\n";}
	#$t_header->param('POS_loop',\@POS_loop);

	# multilinguisme links
        my @lang_lst=split(/:/,$lang_lst_param);
            if ($debug) {print STDERR "$lang_lst_param:$file_out ";}
        foreach $lang_show (@lang_lst) {
            if ($debug) {print STDERR "$lang_show";}
            $lang_show=lc($lang_show);
            $fo_lang=$photo_name_file;
            $fo_lang=~s/out/$lang_show/;
	    if ($lang_show eq 'fr') { # default naming for french
		#$t_content->param("doc_local_fr",out_dir."$photo_name_file_head.html");
           	#$t_content->param("lang_$lang_show","/".$fo_lang);
	    } else {
		#$t_content->param("doc_local_$lang_show",$photo_name_file_head.'_'.$lang_show.".html");
           	#$t_content->param("lang_$lang_show","/".$fo_lang);
	    }
	   if ($debug) {print STDERR "lang_$lang_show->$fo_lang\n ";}
        }

		#
		# Footer
		#
		$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer$lang_param.tmpl.html",die_on_bad_params=>0, utf8=>1);
        my $marqueur=$album_title;
		$marqueur=~s/\s/_/g;
		$marqueur=~s/\'/_/g;
		$t_footer->param('marqueur',$marqueur);
		$t_footer->param('version_dev',$version_dev);

		#
		# Content 
		#
		$t_content=HTML::Template->new(filename=>"$local_tmpl/page_detail$lang_param.tmpl.html",die_on_bad_params=>0, utf8=>1);
		$t_content->param('date_now',$date_now);
		#if ($photo_ref) {$t_content->param('photo_ref',"R-".$photo_ref);} else {$t_content->param('photo_ref','NA');};
		$t_content->param('photo_ref',"R-".$photo_ref);
		$t_content->param('photo_id',$photo_id);

		#Dimension
		my $res_x=&sql_get($dbh,"select resolution_x from photo where id=$photo_id");
		my $res_y=&sql_get($dbh,"select resolution_y from photo where id=$photo_id");
		if ($res_x*$res_y>2000000) {
			my $res_x_cm=int($res_x/120*100)/100;
			my $res_y_cm=int($res_y/120*100)/100;
			
			#$t_content->param('doc_title',"R-".$photo_ref." ".$res_x."px x ".$res_y."px - $res_x_cm cm x $res_y_cm cm @ 300 ppp RGB");
			$t_content->param('photo_res',$res_x."px x ".$res_y."px - $res_x_cm cm x $res_y_cm cm @ 300 ppp RGB");
		} else {
			$t_content->param('doc_title',$photo_name);
			##$t_content->param('doc_title',"Ref R-".$photo_ref." résolution sur demande");
			$t_content->param('photo_res',"résolution sur demande");
		}
	
		#####EXTRA
		my %loop='';
		my $sql="SELECT DISTINCT photo.id,photo.thumb_file,photo.site_img,photo.site_thb,photo.sernum,album_photo.display_order FROM photo,album_photo where photo.id=album_photo.photo_id AND album_id=$album_id and album_photo.publish=1  ORDER BY album_photo.display_order";

		my $sth = $dbh->prepare($sql);
		$sth->execute();

		my ($id,$tf,$cnt,@loop1,$loop,$site_img,$site_thb,$pr,$do);
		$sth->bind_columns(\$id,\$tf,\$site_img,\$site_thb,\$pr,\$do);
		while ($sth->fetch()) {
			 $tf=~s/\\//g;
	  		my $urlphoto=$tf;$urlphoto=~s/^thb-//;
	                $urlphoto=~s/\\//g;
	                my $photo_dir=$web_host_img{$site_img};
	                #$urlphoto=~s/ /%20/g;
			my %ix=('photo_url'=>"$photo_dir/$urlphoto",'doc_title'=>$photo_name,'photo_id'=>"R-".$pr);
			if (-e '/home/data/prod/r2/media/'.$urlphoto) {
				push  @loop,\%ix;
			}
		}
		$sth->finish();
        	$t_content->param('photo_list',\@loop);

		#####EXTRA
		# multilinguisme links
		my @lang_lst=split(/:/,$lang_lst_param);
		if ($debug) {print STDERR "\nLP: $lang_lst_param:$file_out \n ";}
		foreach $lang_show (@lang_lst) {
		    if ($debug) {print STDERR "LS: $lang_show";}
		    $lang_show=lc($lang_show);
		    $fo_lang=$photo_name_file;
		    $fo_lang=~s/out/$lang_show/;
			my $ptitle=$photo_name_file;
			$ptitle=~s/_fr//g;
			$ptitle=~s/_en//g;
			$ptitle=~s/_it//g;
			$ptitle=~s/_es//g;
			$ptitle=~s/.html//g;
			$ptitle=~s/\s/_/g;
			$ptitle=~s/__/_/g;
			$ptitle=~s/\'/_/g;
			$ptitle=~s/_$//;
			$ptitle=~tr/éèêëàâôöùñóí/eeeeaaoounoi/;
			#$ptitle=decode_utf8($ptitle);
                $ptitle=unac_string($ptitle);

		    if ($lang_show eq 'fr') { # default naming for french
			$t_content->param("doc_local_fr","/".$out_dir.$ptitle.".html");
			$t_content->param("lang_$lang_show","/".$fo_lang);
		    } else {
			$t_content->param("doc_local_$lang_show","/".$out_dir.$ptitle.'_'.$lang_show.".html");
			$t_content->param("lang_$lang_show","/".$fo_lang);
		    }
		   if ($debug) {print STDERR " $ptitle  lang_$lang_show->$fo_lang\n ";}
		}

  		## doc_title
		if ($lang_param eq '_en') {
				$t_content->param('doc_title',"$place_name by $first_name $last_name");
				$t_content->param('doc_description',"$place_name of $place_town by $first_name $last_name");
				$photo_keywords="romanesque, art, architecture, gothic, church, abbey, cathedral, cistercian, medieval, middle-age, patrimoiny, sculpture";
		} elsif ($lang_param eq '_es') {
				$t_content->param('doc_title',"$place_name por $first_name $last_name");
				$t_content->param('doc_description',"$place_name de $place_town por $first_name $last_name");
				$photo_keywords= "romanico, arte, architectura, gothico, iglesia, monasterio, catedral, cistercian, medieval, esculptura";
		} elsif ($lang_param eq '_it') {
				$t_content->param('doc_title',"$place_name por $first_name $last_name");
				$t_content->param('doc_description',"$place_name por $place_town por $first_name $last_name");
				$photo_keywords= "roman, art, architecture, gothique, chiesa, Abbazia, cathédrale, cisterciense, cisterciensene, medioevale, moyen-age, romanica, patrimoine, scultura, romanicas, romanicasque";
		} else {
				$t_content->param('doc_title',"$place_name par $first_name $last_name");
				$t_content->param('doc_description',"$place_name de $place_town par $first_name $last_name");
		}
		$t_content->param('doc_keywords',$photo_keywords);

		my $thb_fic=&sql_get($dbh,"SELECT photo.thumb_file FROM photo,album_photo where photo.id=album_photo.photo_id AND album_id=$album_id and album_photo.publish=1 LIMIT 1");
	  	my $alb_photo=$thb_fic;$alb_photo=~s/^thb-//;
	        $alb_photo=~s/\\//g;
		$alb_photo="/media/".$alb_photo;
		$t_content->param('photo_photo',$alb_photo);
		$t_content->param('photo_place',$place_name);
		$t_content->param('photo_city',$place_town);
		$t_content->param('photo_when',$creation);
		$t_content->param('photo_author',"$first_name $last_name");
		$t_content->param('photo_comment',$album_comment);
		#Sites proximité
		$t_content->param('site_region_next',\@tab_site_region_next);
		$t_content->param('site_region_id',\@tab_site_region_id);
		
		my $urlphoto=$thumb_file;$urlphoto=~s/^thb-//;
		$urlphoto=~s/\\//g;
		my $photo_dir=$web_host_img{$site_img};
		$t_content->param('photo_url',"$photo_dir/".$urlphoto);

		$t_content->param('album_title',$album_title);
		# Site Map
		if ($map) {
				$t_content->param('map',1);
				$t_content->param('map_url',$map_url);
				$t_content->param('map_img_low',$map_img_low);
				$t_content->param('map_source_text',$map_source_text);
				$t_content->param('map_source_url',$map_source_url);
				$t_content->param('map_source_book_id',$map_source_book_id);
		}

	#LO:photo_related
	$sql = "SELECT link.id,link.url,link.name,link.lang FROM link_album,link WHERE link_album.album_id=$album_id AND link_album.link_id=link.id and publish=1 order by display_order";
	if ($debug) {print $sql."\n"}
        $sth = $dbh->prepare($sql);
        $sth->execute();
        my ($id,$url,$val,$lang);
        my @tab_link;
        $sth->bind_columns(\$id,\$url, \$val, \$lang);
        while ($sth->fetch()) {
			$val=~s/\\\'/\'/g;
            my %tab=('photo_related_link'=>$url,'photo_related_description'=>$val,"photo_related_lang_$lang"=>$lang);
            push(@tab_link,\%tab);
        }
        $sth->finish();
	$t_content->param('photo_related',\@tab_link);

	#LO:book_related
	my (@tab_book_link);
        $sql = "select distinct cross_classification_book.book_id,book.title,book.author,book.url_picture,book.url,book.lang from cross_classification_book,book,cross_classification where cross_classification_book.classification_id=cross_classification.id_rel and cross_classification.photo_id=$photo_id and cross_classification_book.book_id=book.id ORDER BY book.author";
	if ($debug) {print $sql."\n"}
        $sth = $dbh->prepare($sql);
        $sth->execute();
        my ($id,$url,$img_url,$author,$title,$lang);
        my @tab_link;
        $sth->bind_columns(\$id, \$title, \$author, \$img_url, \$url, \$lang);
        while ($sth->fetch()) {
		next if (! $url);
		if ($author eq 'null') { $author='';};
		$lang=lc($lang);
            	my %tab=('book_related_link'=>$url,'book_related_img'=>$img_url,'book_related_description'=>"$title, $author","book_related_lang_$lang"=>$lang);
            	push(@tab_book_link,\%tab);
        }
        $sth->finish();
        $t_content->param('book_related',\@tab_book_link);


		# Prev photo
		my $prev_photo_nr;
		if ($photo_nr!=1) {
			#$prev_photo_nr=$tab_photo[$photo_nr-1];
			$prev_photo_nr=$photo_nr-1;
		} else {
			#$prev_photo_nr=$tab_photo[$#tab_photo];
			$prev_photo_nr=$#tab_photo;
		}
			#$t_content->param('thumbprev',"$photo_thumb_dir/thumb/".$prev_url);

			my $photo_name_file_prev=$titlestrip."_".&pad_number($prev_photo_nr).$lang_param.".html";	
			$photo_name_file_prev=~tr/îéèàâ/ieeaa/;
			$t_content->param('prev',$photo_name_file_prev);
			$t_content->param('index',"index$lang_param.html");

		# Next photo
		my $next_photo_nr;
		if ($photo_nr>$#tab_photo) {
			$next_photo_nr=1;
		} else {
			$next_photo_nr=$photo_nr+1;
		}

			$next_url=~s/\\//g;


	my $photo_name_file_next=$titlestrip."_".&pad_number($next_photo_nr).$lang_param.".html";
        $photo_name_file_next=~tr/îéèàâ/ieeaa/;
	$t_content->param('next',$photo_name_file_next);


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


	foreach $fic ('lst_cister','lst_roman','lst_gothic','lst_medieval') {	
			open(F1,"<:encoding(utf8)","$local_tmpl/$fic$lang_param.html")|| die "\nError: $local_tmpl/$fic$lang_param.html : $!\n";
			my $lst;
			while(<F1>) {
				$lst.=$_;
			}
			close(F1);
			$t_content->param("$fic",$lst);
	}


	# Save to file
	if (! -d $relocation_path.$out_dir) {
		mkdir $relocation_path.$out_dir;
	}
	
	if (-e $relocation_path.$out_dir.$photo_name_file) {
		unlink $relocation_path.$out_dir.$photo_name_file  || die "Unlink error: $!\n";
	}
	open(FIC,">".$relocation_path.$out_dir.$photo_name_file) || die "Creation error of $out_dir$photo_name_file: $!\n";
	#print FIC $t_header->output;
	print FIC $t_content->output;
	#print FIC Encode::encode("UTF-8",$t_content->output);
	#print FIC $t_footer->output;
	close(FIC);

#
# Generate index file
#




	# Save to file
	if ($debug) {print STDERR "Generating:".$relocation_path.$out_dir."/".$photo_album_file." \n";}
	open  FIC,">".$relocation_path.$out_dir."/".$photo_album_file || die "Error: $!\n";
	print FIC "<HTML><HEAD><SCRIPT language=\"javascript1.3\">window.location.href=\"$photo_name_file\";</SCRIPT></HEAD></HTML>";
	close(FIC);


$dbh->disconnect;
#print STDERR " ok\n";
exit;







sub get_country() {
	my $country_id=shift(@_);
	my $lang_id=shift(@_);
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='name';}
	$sql = "SELECT country.".$lang_id." FROM country where country.id=$country_id";
	if ($debug) {print $sql."\n"}
	$sth = $dbh->prepare($sql);
	$sth->execute();


	my ($pstring);
	$sth->bind_columns(\$pstring);
	while ($sth->fetch()) {
		$cstring=$pstring;
	}
	$sth->finish();
	chomp($cstring);
	return ($cstring);
}

sub get_region() {
	my $album_id=shift(@_);
	my $lang_id=shift(@_);
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='title';}
	# Get Local places
	#

	my $department=substr($postcode,0,2);my $region_id;
	if (($country==250)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	#if ($debug) {print STDERR "Lieu: $postcode-$department-$country-\n";}	

	if (($country==250)||($country==756)) {
		$department=substr($postcode,0,2);
		if (($country==250)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	}
		# Region name
		#
        if ($country==250) {

				$sql = "SELECT region_state.".$lang_id.",region.title,region.id FROM region,region_state where region.id=\'$department\' and region_state.id=region.region_id";
				if ($debug) {print STDERR $sql."\n"}
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
		chomp($g_region_name);
		$g_region_name=$g_region_name;
		$g_department_name=$g_department_name;
		return ($g_region_name,$region_id,$g_department_name);
}

sub show_usage {
    print "ROMANES3 make-page v$version_dev\n";
    print "Usage:\n";
    print "\tmake-page.pl [options] album_number destination_directory generation_language language_list:\n";
    print "\n";
    print "\tOptions:\n\n";
    print "\t-V\t\t\tPrint version\n";
    print "\t-d\t\t\tVerbose mode\n";
    print "\t-h\t\t\tPrint usage message\n";
	print "\t-l\t\t\tMultilinguism generation\n";
	print "\t-s\t\t\tRegenerate close sites\n";
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

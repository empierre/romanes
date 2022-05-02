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
#my $debug=1;

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
if (length($ARGV[0])<1) {
    &show_usage;
    exit 64;
}



#mysql> select count(distinct original_file) from photo;
#select count(*) from place;
#select count(distinct url) from link;

# Parameters
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];
my $lang_param=$ARGV[2];

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
if (! -d $out_dir) {
	mkdir $out_dir;
}

my $local_tmpl="/mnt/data/web/dev/romanes2.com/templates/";
my $photo_album_file="index.html";

my @tab_site_region_next=();
my @tab_site_region_id=();

# DB Connection
my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");


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

print STDERR "Generating pages...";

		# Get Local places
		#

		my $department=substr($postcode,0,2);
		if (($country==33)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
		#print STDERR "$postcode-$department-$country-\n";	

		if (($country==33)||($country==41)) {
				my $department=substr($postcode,0,2);
				if (($country==33)&&(length($postcode)<5)) {$department="0".substr($department,0,1);}
	
				# Same region sites
				#
				my $sql = "SELECT distinct album.url,place.name from photo,album_photo,album,place  where photo.place_id=place.id and place.postcode rlike '^$department' and album_photo.photo_id=photo.id and album.id=album_photo.album_id";
				my $sth = $dbh->prepare($sql);
				$sth->execute();

				my ($site_same_dept_count);
				my ($arg1,$arg2);
				$sth->bind_columns(\$arg1,\$arg2);

				while ($sth->fetch()) {
					$site_same_dept_count++;
					my %tab=('site_url'=>$arg1,'site_title'=>$arg2);
					push @tab_site_region_id,\%tab if (length($arg1)>3);
					
				}
				$sth->finish();

				# Near Region Sites	
				#
				$sql = "SELECT list from region_proxy where id='$department'";
				#print STDERR "$sql\n";
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

						my $sql = "SELECT distinct album.url,place.name from photo,album_photo,album,place  where photo.place_id=place.id and place.postcode rlike '^$department_proxy' and album_photo.photo_id=photo.id and album.id=album_photo.album_id";
						#print STDERR "$sql\n";
						my $sth = $dbh->prepare($sql);
						$sth->execute();

						my ($site_next_dept_count);
						my ($arg1,$arg2);
						my @tab_site_region_next_local;
						my $site_next_dept_count;

						$sth->bind_columns(\$arg1,\$arg2);
						
						while ($sth->fetch()) {
							$site_next_dept_count++;
							my %tab=('site_url'=>$arg1,'site_title'=>$arg2);
							push @tab_site_region_next_local,\%tab  if (length($arg1)>3);

						}
						$sth->finish();

						# Region name
						#
						$sql = "SELECT title FROM region where id=$department_proxy";
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
				}
		}

		# Site Map
		#
		my $sql="SELECT map_url,map_img_low,map_source_text,map_source_url,map_source_book_id FROM map where album_id=$album_id";

        my $sth = $dbh->prepare($sql);
        $sth->execute();

        my ($umap_url,$umap_img_low,$umap_source_text,$umap_source_url,$umap_source_book_id);
        my ($map_url,$map_img_low,$map_source_text,$map_source_url,$map_source_book_id);
        $sth->bind_columns(\$umap_url,\$umap_img_low,\$umap_source_text,\$umap_source_url,\$umap_source_book_id);

        while ($sth->fetch()) {

			if ($umap_img_low) {
				$map=1;
				$map_url=$umap_url;
				$map_img_low=$umap_img_low;
				$map_source_text=$umap_source_text;
				$map_source_url=$umap_source_url;
				$map_source_book_id=$umap_source_book_id;
			}
		}


# Treat all picture in album
#
$sql = "SELECT photo_id FROM album_photo where album_id=$album_id AND publish=1 ORDER BY display_order";
$sth = $dbh->prepare($sql);
$sth->execute();

my @tab_photo;
my ($photo);
$sth->bind_columns(\$photo);

while ($sth->fetch()) {
	push @tab_photo,$photo;
}
$sth->finish();


my $photo_name_file;my $photo_name_toprint_file;my $photo_nr=1;
foreach $photo_id (@tab_photo) {
		# Photo name
		$photo_name_file=$titlestrip."_".&pad_number($photo_nr).$lang_param.".html";
		$photo_name_file=~tr/???????/ieeaaoo/;
		#$photo_name_toprint_file=$titlestrip."_".$photo_id."_print.html";
		$photo_album_file="index.html";

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
		$sth = $dbh->prepare($sql);
		$sth->execute();
		
		my ($pkeywords,$photo_keywords);
		$photo_keywords="$place_name, $place_town, ";
		$sth->bind_columns(\$pkeywords);
		while ($sth->fetch()) {
			$photo_keywords.=$pkeywords.", ";
		}
		$sth->finish();

		$t_header=HTML::Template->new(filename=>"$local_tmpl/header.tmpl.html",die_on_bad_params=>1);
		$t_header->param('doc_title',"Romanes.com: Art et Architecture Romane, $photo_name par $first_name $last_name");
		$t_header->param('doc_description',"$photo_name de $place_town par $first_name $last_name");
		$t_header->param('doc_keywords',$photo_keywords);

	# Europe / France / Ile de France / Etampes / Notre Dame du Fort

	#POS
	my $ncountry;
	my @POS_loop;
	($g_region_name,$region_id,$g_department_name)=&get_region($album_id);

	push @POS_loop,{'url'=>'/France_fr.html','name'=>'Europe'};
	if ($country==41) {$ncountry="Suisse";}
	if ($country==33) {$ncountry="France";}
	push @POS_loop,{'url'=>'/'.$ncountry.'_fr.html','name'=>$ncountry};
	if ($country==33) {
		push @POS_loop,{'url'=>'/'.$ncountry.'_fr.html#','name'=>$g_region_name};
		push @POS_loop,{'url'=>'/'.$ncountry.'_fr.html#'.$region_id,'name'=>$place_town};
	} else {
		push @POS_loop,{'url'=>'/'.$ncountry.'_fr.html','name'=>$place_town};
	}
	push @POS_loop,{'url'=>'index.html','name'=>$place_name};
	if ($debug) {print STDERR "POS: $album_id $place_town $place_name\n";}
	$t_header->param('POS_loop',\@POS_loop);

		#
		# Footer
		#
		$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer.tmpl.html",die_on_bad_params=>0);
        my $marqueur=$album_title;
		$marqueur=~s/\s/_/g;
		$marqueur=~s/\'/_/g;
		$t_footer->param('marqueur',$marqueur);
		$t_footer->param('version_dev',$version_dev);

		#
		# Content 
		#
		$t_content=HTML::Template->new(filename=>"$local_tmpl/page_detail.tmpl.html",die_on_bad_params=>0);
		$t_content->param('date_now',$date_now);
		#if ($photo_ref) {$t_content->param('photo_ref',"R-".$photo_ref);} else {$t_content->param('photo_ref','NA');};
		$t_content->param('photo_ref',"R-".$photo_ref);
		$t_content->param('photo_id',$photo_id);
		#$name=~s/\\\'/\'/g;
		#$town=~s/\\\'/\'/g;
		#$comment=~s/\\\'/\'/g;
		$t_content->param('photo_place',$place_name);
		$t_content->param('photo_city',$place_town);
		$t_content->param('photo_when',$creation);
		$t_content->param('photo_author',"$first_name $last_name");
		$t_content->param('photo_comment',$album_comment);
		#Sites proximit?
		$t_content->param('site_region_next',\@tab_site_region_next);
		$t_content->param('site_region_id',\@tab_site_region_id);
		
		my $urlphoto=$thumb_file;$urlphoto=~s/^thb-//;
		$urlphoto=~s/\\//g;
		my $photo_dir=$web_host_img{$site_img};
		$t_content->param('photo_url',"$photo_dir/".$urlphoto);
		##Romanes.org $t_content->param('photo_url',"http://www.romanes.org/imageweb/".$urlphoto);
		#my $urlphoto2=$urlphoto;
		#$urlphoto2=~s/_/%20/g;
		#$t_content->param('photo_url',"http://www.romanes.com/Royaumont/".$urlphoto);

		#$t_content->param('photo_print_link',$photo_name_toprint_file);
		#$t_content->param('photo_bigger_link',$photo_wp800x600_dir."wallpaper-".$urlphoto);
		#$t_content->param('photo_biggest_link',$photo_wp1024x768_dir."wallpaper-".$urlphoto);
		#$album_title=~s/\\\'/\'/g;
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
        $sql = "select distinct cross_classification_book.book_id,book.title,book.author,book.url_picture,book.url,book.lang from cross_classification_book,book,cross_classification where cross_classification_book.classification_id=cross_classification.id_rel and cross_classification.photo_id=$photo_id and cross_classification_book.book_id=book.id ORDER BY book.editor";
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
		if ($photo_nr!=0) {
			#$prev_photo_nr=$tab_photo[$photo_nr-1];
			$prev_photo_nr=$photo_nr-1;
		} else {
			#$prev_photo_nr=$tab_photo[$#tab_photo];
			$prev_photo_nr=$#tab_photo;
		}
			#$sql = "SELECT thumb_file FROM photo where id=".$prev_photo_nr;
            #$sth = $dbh->prepare($sql);
            #$sth->execute();
            #my ($pprev_url,$prev_url);
            #$sth->bind_columns(\$pprev_url);
            #while ($sth->fetch()) {
			#	$prev_url=$pprev_url;	
            #}
            #$sth->finish();
			#$prev_url=~s/\\//g;
			#my $photo_thumb_dir = $web_host_thb{};
			#$t_content->param('thumbprev',"$photo_thumb_dir/thumb/".$prev_url);

			my $photo_name_file_prev=$titlestrip."_".&pad_number($prev_photo_nr).$lang_param.".html";	
			$photo_name_file_prev=~tr/?????/ieeaa/;
			$t_content->param('prev',$photo_name_file_prev);

		# Next photo
		my $next_photo_nr;
		if ($photo_nr>=$#tab_photo) {
			#$next_photo_nr=$tab_photo[0];
			$next_photo_nr=0;
		} else {
			#$next_photo_nr=$tab_photo[$photo_nr+1];
			$next_photo_nr=$photo_nr+1;
		}
			#$sql = "SELECT thumb_file FROM photo where id=".$next_photo_nr;
            #$sth = $dbh->prepare($sql);
            #$sth->execute();
            #my ($pnext_url,$next_url);
            #$sth->bind_columns(\$pnext_url);
            #while ($sth->fetch()) {
			#	$next_url=$pnext_url;	
            #}
            #$sth->finish();
			$next_url=~s/\\//g;
            #my $photo_thumb_dir = $web_host_thb{};
			#$t_content->param('thumbnext',"$photo_thumb_dir/thumb/".$next_url);

			my $photo_name_file_next=$titlestrip."_".&pad_number($next_photo_nr).$lang_param.".html";
            $photo_name_file_next=~tr/?????/ieeaa/;
			$t_content->param('next',$photo_name_file_next);


	#LO:photo_thumb
	#my $sql="SELECT DISTINCT photo.id,photo.thumb_file FROM photo,album_photo where photo.id=album_photo.photo_id AND album_id=$album_id ORDER BY album_photo.display_order";
        #$sth = $dbh->prepare($sql);
        #$sth->execute();
        #my ($id,$url_thumb);
        #my @tab_thumb;
        #$sth->bind_columns(\$id,\$url_thumb);
        #while ($sth->fetch()) {
		#	$url_thumb=~s/\\//g;
        #    my %tab=('thumb_img'=>"$photo_thumb_dir/thumb/".$url_thumb,'thumb_url'=>$titlestrip."_$id.html");
        #    push(@tab_thumb,\%tab);
        #}
        #$sth->finish();
	#$t_content->param('thumb_loop',\@tab_thumb);

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


	## Site Quick Index
	#my $list_half=($tsize/2);
		
	# First Half
	#$sql = "SELECT id,url,title,onsite FROM album order by title limit $list_half";
	#$sth = $dbh->prepare($sql);
	#$sth->execute();
	#my ($id,$url,$val,$onsite);
	#my @tab_link;
	#$sth->bind_columns(\$id,\$url, \$val,\$onsite);
	#while ($sth->fetch()) {
	# 	$url=$web_host_album{$onsite}.$url;
	#	my %tab=('url'=>$url,'val'=>$val);
	#	push(@tab_link,\%tab);
	#}
	#$sth->finish();
	#$t_content->param('site_index_loop1',\@tab_link);

	## Second Half
	#$sql = "SELECT id,url,title,onsite FROM album order by title limit $list_half,$tsize";
	#$sth = $dbh->prepare($sql);
	#$sth->execute();
	#my ($id,$url,$val,$onsite);
	#my @tab_link;
	#$sth->bind_columns(\$id,\$url, \$val,\$onsite);
	#while ($sth->fetch()) {
	# 	$url=$web_host_album{$onsite}.$url;
	#	my %tab=('url'=>$url,'val'=>$val);
	#	push(@tab_link,\%tab);
	#}
	#$sth->finish();
	#$t_content->param('site_index_loop2',\@tab_link);

	foreach $fic ('lst_cister','lst_roman','lst_gothic','lst_medieval') {	
			open(F1,"$local_tmpl/$fic$lang_param.html")|| die "\nError: $local_tmpl/$fic$lang_param.html : $!\n";
			my $lst;
			while(<F1>) {
				$lst.=$_;
			}
			close(F1);
			$t_content->param("$fic",$lst);
	}

	# Save to file
	if (-e $out_dir.$photo_name_file) {
		unlink $out_dir.$photo_name_file  || die "Unlink error: $!\n";
	}
	open(FIC,">".$out_dir.$photo_name_file) || die "Creation error of $out_dir$photo_name_file: $!\n";
	print FIC $t_header->output;
	print FIC $t_content->output;
	print FIC $t_footer->output;
	close(FIC);

	#exit;
	$photo_nr++;
}




if ($photo_nr<1) {
	print STDERR  "ok No index to generate\nexiting...\n";
	exit;
	}
		print  STDERR "ok ($photo_nr generated)\nGenerating index...";
		print "$photo_nr files:index\n";
		#
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



$dbh->disconnect;
print STDERR "ok\n";
exit;

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

				$sql = "SELECT departement.title,region.title,region.id FROM region,departement where region.id=$department and departement.id=region.region_id";
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

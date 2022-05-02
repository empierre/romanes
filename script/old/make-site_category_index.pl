#!/usr/bin/perl
#
#
#
#TODO:
# - per region for france => useless
# - use NEW
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;

#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

#version
my $version_dev="1.0.5d";
my $debug=0;



#Updated for templates/pages/regions
# Make a list of site per regions

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
my $dbh1 = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");
&sql_update($dbh1,"SET NAMES utf8");

my $local_tmpl='/mnt/data/web/dev/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";

my %web_host_img=(
	"9" => "http://www.romanes.org/",
	"8" => "http://www.romanes.com/",
	"1" => "http://romanes.free.fr/",
	"2" => "http://romanes2.free.fr/",
	"3" => "http://romanes3.free.fr/",
	"4" => "http://romanes4.free.fr/",
    "5" => "http://emmanuel.pierre2.free.fr/",
    "6" => "http://aaea.free.fr/",
    "7" => "http://aaea2.free.fr/"
);
my %web_host_thb=(
	#"1" => "http://perso.orange.fr/e-nef/"
	"1" => "http://www.romanes.org/"
);
my %web_host_album=(
	"9" => "http://www.romanes.org/",
	"8" => "http://www.romanes.com/",
	"1" => "http://romanes.free.fr/",
	"2" => "http://romanes2.free.fr/",
	"3" => "http://romanes3.free.fr/",
	"4" => "http://romanes4.free.fr/",
    "5" => "http://emmanuel.pierre2.free.fr/",
    "6" => "http://aaea.free.fr/",
    "7" => "http://aaea2.free.fr/"
);
my $reference_onsite=8;

# Parameters
my $lang_param=$ARGV[0]||'fr';
my $lang_lst_param=$ARGV[1]||'';

#Generate site list
#
#
#foreach $style ('Roman','Gothique','Medieval','Cistercien') {
foreach $style ('Gothique','Medieval') {
	print STDERR "Generating $style";

	#if ($style eq 'Roman') {
	#	$sql="select distinct  id,title from album where epoch_style rlike 'roman' or epoch_style rlike 'benedictin' or epoch_style rlike 'cluny' order by title;";
	#} els
	if ($style eq 'Medieval') {
		$sql="select id,title from album where epoch_style rlike 'm?di?val' order by title;";
	} elsif ($style eq 'Cistercien') {
		$sql="select id,title from album where epoch_style rlike 'cistercien' order by title;";
	} elsif ($style eq 'Gothique') {
		$sql="select id,title from album where epoch_style rlike 'gothique' order by title;";
	}
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	my ($pid,@f_region,$ptitle);
	$sth->bind_columns(\$pid,\$ptitle);
	print STDERR ".";
	while ($sth->fetch()) {
		push @f_region,$pid;
	}
	print STDERR ".";
	&generate_liste_index("$local_tmpl/pages/liste_site_".$style."_$lang_param.tmpl.html",$style,2,$lang_param,$lang_lst_param,@f_region);
}	
	#
	# Roman
	#
	$style='Roman';
	print STDERR "Generating $style";
	if ($style eq 'Roman') {
		my $sql="select id,title from region_state order by title";
		my $sth = $dbh1->prepare($sql);
		$sth->execute();
		my ($pid,@f_region,$ptitle);
		$sth->bind_columns(\$pid,\$ptitle);
		#print STDERR ".";
		while ($sth->fetch()) {
			push @f_region,$pid;
			$ptitle=&get_region($pid,$lang_param);
			$ptitle=~s/\'/\\\'/g;
			$ptitle=~s/_/ /g;
			push @tab_menu,{'region_url'=>'#F'.$pid,"region_name_fr"=>$ptitle};
			#print STDERR "$pid-$ptitle\n";
		}
		&generate_region("$local_tmpl/pages/liste_site_".$style."_$lang_param.tmpl.html",$style,0,2,250,'_'.$lang_param,@f_region);
	}
	
	print STDERR ". ok\n";


$dbh->disconnect;
print STDERR "Done\n";
exit;


sub generate_liste_index {
		my $tmpl_name=shift(@_);
		my $style=shift(@_);
		my $item_per_line=shift(@_)-1;
		my $lang_param=shift(@_);
		my $lang_lst_param=shift(@_);
		
		my @album_list;my @site_loop;
		foreach (@_) { push @album_list,$_;}
		if ($debug) {print STDERR "$tmpl_name-$style-$item_per_line-".join(':',@album_list)."\n";}


		my $odd_even=0;my %tab={};#my @tab_menu;
		my $loop;my $cnt;my @loop1;my @loop0;my $reg_cnt;
		foreach my $v (@album_list) {

			my $sql="select photo.id,photo.place_id,photo.thumb_file,album.title,photo.resolution_x,photo.resolution_y,album.url,place.town,album.epoch_str,album.epoch_style,album.onsite from photo,album,album_photo,place where album.id=album_photo.album_id and album_photo.photo_id=photo.id and album_photo.publish=1 and place.id=photo.place_id and album.id=$v order by album_photo.display_order limit 1";
			#if ($debug) {print $sql."\n";}
			my $sth = $dbh->prepare($sql);
			$sth->execute();
			my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str,$epoch_style,$px,$py,$town_name,$onsite);
			my %mem_dep;
			$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$px,\$py,\$album_url,\$town_name,\$epoch_str,\$epoch_style,\$onsite);
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
					%ix=('thb_url'=>"http://www.romanes.org/thumb/$tf",'place_name_fr'=>$nm,'album_url'=>$web_host_album{$onsite}.$album_url."/index$lp.html",'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str,'style'=>$epoch_style,'BGC'=>'#E6E6D2');
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
		push @site_loop,{'title_name_fr'=>&get_country(250,$lang_param)." -  $style",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
	
	#POS
	my @POS_loop;
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/France_fr.html','name'=>&get_country(250,$lang_param)};
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.$style.'_fr.html','name'=>$style};

	#Include regional text
	my $region_intro;
	if (-e $local_tmpl."pages/regions/".$region_name."_$lang_param.html") {
		open(REG,$local_tmpl."pages/regions/".$region_name."_$lang_param.html");
		while(<REG>) {
			$region_intro.=$_;
		}
	}

	my $t_footer;
	my $t_header;
	my $t_content;
	
		#
		# Header
		#
		$t_header=HTML::Template->new(filename=>"$local_tmpl/header_$lang_param.tmpl.html",die_on_bad_params=>1);
		if ($lang_param eq '_en') {
				$t_header->param('doc_title',"Romanes.com: Romanesque Art and Architecture, $style");
				$t_header->param('doc_description',"$style");
				$photo_keywords="romanesque, art, architecture, gothic, church, abbey, cathedral, cistercian, medieval, middle-age, patrimoiny, sculpture";
		} elsif ($lang_param eq '_es') {
				$t_header->param('doc_title',"Romanes.com: Romanica, G&oacute;tico Arte y Arquitectura, $style");
				$t_header->param('doc_description',"$style");
				$photo_keywords= "romanico, arte, architectura, gothico, iglesia, monasterio, catedral, cistercian, medieval, esculptura";
		} else {
				$t_header->param('doc_title',"Romanes.com: Art et Architecture Romane, $style");
				$t_header->param('doc_description',"$style");
				$photo_keywords= "roman, art, architecture, gothique, ?glise, abbaye, cath?drale, cistercien, cistercienne, m?di?val, moyen-age, romane, patrimoine, sculpture, romanes, romanesque";
		}
		$t_header->param('doc_keywords',$photo_keywords);
		
		# multilinguisme links
		my @lang_lst=split(/:/,$lang_lst_param);
        if ($debug) {print STDERR "$lang_lst_param:$file_out ";}
        foreach $lang_show (@lang_lst) {
            if ($debug) {print STDERR "$lang_show";}
            $lang_show=lc($lang_show);
            $fo_lang=$photo_name_file;
            $fo_lang=~s/out/$lang_show/;
			$t_header->param("doc_local_$lang_show","$style_$lang_show.html");
			$t_header->param("lang_$lang_show","/".$fo_lang);
			if ($debug) {print STDERR "lang_$lang_show->$fo_lang\n ";}
        }
	
	#
	# Footer
	#
	$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer_$lang_param.tmpl.html",die_on_bad_params=>0);
    my $marqueur="Site_List_France";
	$marqueur=~s/\s/_/g;
	$marqueur=~s/\'/_/g;
	$t_footer->param('marqueur',$marqueur);
	$t_footer->param('version_dev',$version_dev);
	
	#
	#Publish
	#
	
	$t_content=HTML::Template->new(filename=>$tmpl_name,die_on_bad_params=>0);
	$t_content->param('site_loop',\@site_loop);
	$t_content->param('region_list',\@tab_menu);
	$t_content->param('region_name_fr',$style);
	$t_content->param('region_intro',$region_intro);
	$t_header->param('POS_loop',\@POS_loop);

	open(FIC,">".$style."_$lang_param.html");
	print FIC $t_header->output;
	print FIC $t_content->output;
	print FIC $t_footer->output;
	close(FIC);
}

sub generate_region {
		my $tmpl_name=shift(@_);
		my $region_name=shift(@_);	
		my $region_id=shift(@_);		
		my $item_per_line=shift(@_);
		my $country=shift(@_);
		my $lang_param=shift(@_);
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

				my $sql="select photo.id,photo.place_id,photo.thumb_file,album.title,photo.resolution_x,photo.resolution_y,album.url,place.town,album.epoch_str,album.epoch_style,album.onsite from photo,place,album,album_photo where album.id=album_photo.album_id and album_photo.photo_id=photo.id and photo.place_id=place.id and place.postcode rlike '^$v' AND album_photo.publish=1 and (epoch_style rlike 'roman' or epoch_style rlike 'benedictin' or epoch_style rlike 'cluny') order by album_photo.display_order";
				my $sth = $dbh->prepare($sql);
				$sth->execute();
				my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str,$epoch_style,$px,$py,$town_name,$album_onsite);
				my %mem_dep;
				$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$px,\$py,\$album_url,\$town_name,\$epoch_str,\$epoch_style,\$album_onsite);
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
						%ix=('thb_url'=>"http://www.romanes.org/thumb/$tf",'place_name_fr'=>$nm,'album_url'=>$web_host_album{$album_onsite}.$album_url."/index$lp.html",'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str,'style'=>$epoch_style,'BGC'=>'#E6E6D2');
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
			my $region_name=&get_region($k,$lang_param);
			$region_name=~s/_/ /g;
			my $country_name=&get_country($country,$lang_param);
			push @site_loop,{'title_name_fr'=>"$country_name -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
			#if ($region_name eq 'France') {push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};}
			#my @loop3;
			#$loop0=\@loop3;

		}

		$t_header=HTML::Template->new(filename=>"$local_tmpl/header$lang_param.tmpl.html",die_on_bad_params=>1);
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
	push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.&get_country($country,'fr').$lang_param.'.html','name'=>$ncountry};

	#if ($region_name ne &get_country($country,$lang_param)) {
	if ($region_id) {
	  #if ($country==250) {
		  my $ptitle=$g_region_name;
		  chomp($ptitle);
		  $ptitle=~s/\s/_/g;
		  $ptitle=~s/__/_/g;
		  $ptitle=~s/\'/_/g;
		  $ptitle=~s/_$//;
    	  $ptitle=~tr/???????????_/eeeaaoouoin /;
		  push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/'.$ptitle.($lang_param||'_fr').'.html#','name'=>$g_region_name};		  
	   #}
	}
	if ($debug) {print STDERR "POS: $album_id $place_town $place_name\n";}
	$t_header->param('POS_loop',\@POS_loop);
	
		#
		# Footer
		#
		$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer$lang_param.tmpl.html",die_on_bad_params=>0);
        my $marqueur=$album_title;
		$marqueur=~s/\s/_/g;
		$marqueur=~s/\'/_/g;
		$t_footer->param('marqueur',$marqueur);
		$t_footer->param('version_dev',$version_dev);

		#Include regional text
		my $region_intro;
		if (($region_name eq 'Centre')||($region_name eq 'Picardie')) {
		    if (-e $local_tmpl."pages/regions/Ile_de_France$lang_param.html") {
			open(REG,$local_tmpl."pages/regions/Ile_de_France$lang_param.html");
			while(<REG>) { $region_intro.=$_; }
		  }
		} elsif (-e $local_tmpl."pages/regions/".&get_region($region_id,'fr')."$lang_param.html") {
			open(REG,$local_tmpl."pages/regions/".&get_region($region_id,'fr')."$lang_param.html");
			while(<REG>) { $region_intro.=$_; }
		}

		# language flags
		my @lang_lst=split(/:/,$lang_lst_param);
        if ($debug) {print STDERR "$lang_lst_param:$file_out ";}
        foreach $lang_show (@lang_lst) {
            if ($debug) {print STDERR "$lang_show";}
            $lang_show=lc($lang_show);
            $fo_lang=$photo_name_file;
            $fo_lang=~s/out/$lang_show/;
			my $ptitle=&get_region($region_id,$lang_show);
			$ptitle=~s/\s/_/g;
		    $ptitle=~s/__/_/g;
		    $ptitle=~s/\'/_/g;
		    $ptitle=~s/_$//;
    	    $ptitle=~tr/???????????/eeeaaoouoin/;
			$t_header->param("doc_local_$lang_show",$ptitle.'_'.$lang_show.".html");
            $t_header->param("lang_$lang_show","/".$fo_lang);
			if ($debug) {print STDERR "lang_$lang_show->$fo_lang\n ";}
        }
	
		#
		#Publish
		#
		my $t_content;
		$t_content=HTML::Template->new(filename=>$tmpl_name,die_on_bad_params=>0);
		$t_content->param('region_name_fr',$region_name);
		$t_content->param('site_region',$region_name);
		$t_content->param('site_loop',\@site_loop);
		$t_content->param('region_list',\@tab_menu);
		$t_content->param('region_intro',$region_intro);
		$t_content->param('region_name_categ_fr',$region_name);

   	  	$region_name=~tr/???????????/eeeaaoouoin/;
		open(FIC,">".$region_name."$lang_param.html")|| warn "ERR:$region_name $!\n";
		print FIC $t_header->output;
		print FIC $t_content->output;
		print FIC $t_footer->output;
		close(FIC);
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

sub get_country() {
	my $country_id=shift(@_);
	my $lang_id=shift(@_);
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='name';}
	$sql = "SELECT country.".$lang_id." FROM country where country.id=$country_id";
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
	my $region_id=shift(@_);
	my $lang_id=shift(@_);
	$lang_id=~s/_//;
    if (($lang_id eq 'fr')||($lang_id  eq '')) {$lang_id='title';}
	my $sql = "SELECT region_state.".$lang_id." FROM region_state where region_state.id=$region_id";
	my $sth = $dbh->prepare($sql);
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
	return ($cstring);
}

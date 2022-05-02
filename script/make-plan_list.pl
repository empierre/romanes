#!/usr/bin/perl
#
#
# $local_tmpl/pages/map_fr.tmpl.html
#

use Unicode::Normalize;
use Text::Unaccent::PurePerl qw(unac_string);
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);
use Date::Manip;
use Getopt::Std;
use Fcntl;
use Encode;


#DT
$TZ='GMT';
$Date::Manip::TZ="GMT";
my $date_now=&UnixDate("today","%Y-%m-%e");

#version
my $version_dev="1.0.6";
my $debug=0;

# Gnerate a plan list per region

my $dbh = DBI->connect("DBI:mysql:ROMANES3;127.0.0.1",'root',undef)  or die "Unable to connect to Contacts Database: $dbh->errstr\n";
&sql_update($dbh,"SET NAMES utf8");


my $local_tmpl='/mnt/data/web/prod/romanes2.com/templates/';
#my $local_tmpl='/cygdrive/c/Documents and Settings/Emmanuel PIERRE/romanes/templates/';
#my $hosting="http://www.romanes.com/";
my $hosting="";
my %web_host_img=(
        "1"=>"http://www.romanes.com/media/",
        "2"=>"http://www.romanes.com/media/",
        "3"=>"http://www.romanes.com/media/",
        "4"=>"http://www.romanes.com/media/",
        "5"=>"http://www.romanes.com/media/",
        "6"=>"http://www.romanes.com/media/",
        "7"=>"http://www.romanes.com/media/",
        "8"=>"http://www.romanes.com/media/",
        "9"=>"http://www.romanes.com/media/",
        "10"=>"http://www.romanes.com/media/",
        "11"=>"http://www.romanes.com/media/",
        "12"=>"http://www.romanes.com/media/"
);
my %web_host_thb=(
	#"1" => "http://perso.orange.fr/e-nef/"
	#"1" => "http://www.romanes.org/"
        "1"=>"http://www.romanes.com/media/",
);
my %web_host_album=(
        "1"=>"",
        "2"=>"",
        "3"=>"",
        "4"=>"",
        "5"=>"",
        "6"=>"",
        "7"=>"",
        "8"=>"",
        "9"=>"",
        "10"=>"",
        "11"=>"",
        "12"=>""

);
my $reference_onsite=8;

# Parameters
my $lang_lst_param=$ARGV[0]||'fr';

my @lang_lst=split(/:/,$lang_lst_param);
print STDERR "Generating ";
foreach $lang_show (@lang_lst) {
	print STDERR "$lang_show ";
	&make_plan_list('_'.$lang_show,'fr:en:es:it');
}

$dbh->disconnect;
print STDERR "ok\n";
exit;

sub make_plan_list {
my $lang_param=shift(@_);
my $lang_lst_param=shift(@_);

my $t_header;
my $t_content;
my $t_footer;

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


my @tab_site_loop;my @tab_menu;my @site_loop;
my $odd_even=0;my %tab={};
foreach my $k (@t_region) {
	my @l=split(/,/,$l_department{$k});
	my $loop;my $cnt;my @loop1;my $loop0;my @loop0;my $reg_cnt;

	foreach my $v (@l) {

		my $sql="select album.id,album_place.place_id,map.map_img_low,album.title,album.url,place.town,album.epoch_str,album.onsite from map,album,place,album_place where map.album_id=album_place.album_id and album_place.album_id=album.id and album_place.place_id=place.id and place.postcode rlike '^$v' order by place.id";
		my $sth = $dbh->prepare($sql);
		$sth->execute();
		my ($pid,$plid,$nm,$tf,$rx,$ry,$album_url,$place_name,$epoch_str,$onsite);
		my %mem_dep;
		$sth->bind_columns(\$pid,\$plid,\$tf,\$nm,\$album_url,\$town_name,\$epoch_str,\$onsite);
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
				my %ix=('thb_url'=>"$tf",'place_name_fr'=>$nm,'album_url'=>$web_host_album{$onsite}.$album_url,'town_name_fr_1'=>$town_name,'epoch'=>$epoch_str);
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
	my $region_name=&get_region($k,$lang_param);
	push @site_loop,{'title_name_fr'=>&get_country(250,$lang_param)." -  $region_name",'title_id_fr'=>"F$k",'thb_site_loop_line'=>\@loop0} if ($reg_cnt);
	push @tab_menu,{'region_url'=>'#F'.$k,'region_name_fr'=>$region_name};
	#my @loop3;
	#$loop0=\@loop3;

}
#POS
my @POS_loop;
push @POS_loop,{'url'=>$web_host_album{$reference_onsite}.'/France_fr.html','name'=>'France'};


		#
		# Header
		#

		$t_header=HTML::Template->new(filename=>"$local_tmpl/header$lang_param.tmpl.html",die_on_bad_params=>1);
		if ($lang_param eq '_en') {
				$t_header->param('doc_title',"Romanes.com: Romanesque Art and Architecture, Site Plans");
				$t_header->param('doc_description',"Sites plans");
				$photo_keywords="romanesque, art, architecture, gothic, church, abbey, cathedral, cistercian, medieval, middle-age, patrimoiny, sculpture";
		} elsif ($lang_param eq '_es') {
				$t_header->param('doc_title',"Romanes.com: Romanica, G&oacute;tico Arte y Arquitectura, Planos de sitios");
				$t_header->param('doc_description',"Planos de sitios");
				$photo_keywords= "romanico, arte, architectura, gothico, iglesia, monasterio, catedral, cistercian, medieval, esculptura";
		} else {
				$t_header->param('doc_title',"Romanes.com: Art et Architecture Romane, liste des plans de sites");
				$t_header->param('doc_description',"liste des plans de sites");
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
			if ($lang_show eq 'fr') { # default naming for french
				$t_header->param("doc_local_fr","map_list.html");
				$t_header->param("lang_$lang_show","/".$fo_lang);
			} else {
				$t_header->param("doc_local_$lang_show","map_list_$lang_show.html");
				$t_header->param("lang_$lang_show","/".$fo_lang);
			}
			if ($debug) {print STDERR "lang_$lang_show->$fo_lang\n ";}
        }

		#
		# Footer
		#
		$t_footer=HTML::Template->new(filename=>"$local_tmpl/footer$lang_param.tmpl.html",die_on_bad_params=>0);
        my $marqueur="Map_List_France";
		$marqueur=~s/\s/_/g;
		$marqueur=~s/\'/_/g;
		$t_footer->param('marqueur',$marqueur);
		$t_footer->param('version_dev',$version_dev);

#
#Publish
#
my $t_content;
$t_content=HTML::Template->new(filename=>"$local_tmpl/pages/map$lang_param.tmpl.html",die_on_bad_params=>0);
$t_content->param('site_loop',\@site_loop);
$t_content->param('region_list',\@tab_menu);
$t_content->param('region_name_fr',"France");
$t_header->param('POS_loop',\@POS_loop);

# Save to file
if ($lang_param eq '_fr') {$lang_param='';}
open  FIC,">map_list$lang_param.html" || die "Error: $!\n";
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
	$cstring=decode_utf8($cstring);
	return ($cstring);
}
sub sql_update {
	my ($dbh,$sql) = @_;
	my $rc = $dbh->do($sql) or die "Unable to prepare/execute $sql: $dbh->errstr\n";
	return($rc);
}

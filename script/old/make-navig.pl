#!/usr/bin/perl 
# pas localisée => obscolète
# Revision 0.0  2002/01/01 19:27:09  epierre
# adding english comments
#
# (c) 2002 Emmanuel PIERRE
#          epierre@e-nef.com
#          http://www.e-nef.com/users/epierre

#use lib qw (/usr/local/etc/httpd/sites/e-nef.com/htdocs/cgibin/);
#use strict;
use DBI();
use HTML::Template qw();
use Image::Info qw(image_info);

#version
my $version_dev="0.1";

# Parameters
my $file_in=$ARGV[0];
my $file_out=$ARGV[1];
my $lang_param=$ARGV[2]||'';
my $lang_lst_param=$ARGV[3]||'';

if ((!$file_in)&&(!$file_out)) {
	print STDERR "Missing argument\n";
	exit;
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

my %web_host_img=(
	"1" => "http://romanes.free.fr/",
	"2" => "http://romanes2.free.fr/",
	"3" => "http://romanes3.free.fr/",
	"4" => "http://romanes4.free.fr/"
);
my %web_host_thb=(
#	"1" => "http://perso.orange.fr/e-nef/"
        "1" => "http://www.romanes.org/"

);
my %web_host_album=(
	"1" => ""
);

my $local_tmpl="/mnt/data/web/dev/romanes2.com/templates/";

		#
		# Content 
		#
		$t_content=HTML::Template->new(filename=>$file_in,die_on_bad_params=>0);

		foreach $fic ('lst_cister','lst_roman','lst_gothic','lst_medieval','bookmark','lst_region') {	
				open(F1,"$local_tmpl/$fic$lang_param.html")|| die "\nError: $local_tmpl/$fic$lang_param.html : $!\n";
				my $lst;
				while(<F1>) {
					$lst.=$_;
				}
				close(F1);
				$t_content->param("$fic",$lst);
		}

		my @lang_lst=split(/:/,$lang_lst_param);
			print STDERR "$lang_lst_param:$file_out ";
		foreach $lang_show (@lang_lst) {
			print STDERR "$lang_show\n";
			$lang_show=lc($lang_show);
			$fo_lang=$file_out;
			$fo_lang=~s/out/$lang_show/;
			$t_content->param("lang_$lang_show","/".$fo_lang);
			print STDERR "lang_$lang_show->$fo_lang ";
		}

		# Save to file
		if ($lang_param) {
			$file_out=~s/_out/$lang_param/;
		} else {
			$file_out=~s/_out//g;
		}
		print STDERR "$file_out\n";
		open  FIC,">".$file_out || die "Error: $file_out : $!\n";
		print FIC $t_content->output;
		close(FIC);
exit;

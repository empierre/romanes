#!/usr/bin/perl 
#
# Revision 0.0  2002/01/01 19:27:09  epierre
# adding english comments
#
# (c) 2002 Emmanuel PIERRE
#          epierre@e-nef.com
#          http://www.e-nef.com/users/epierre

#use strict;
use HTML::Template qw();

my $file_in=@ARGV[0];
my $file_out=$ARGV[1];
my $lang_param=$ARGV[2]||'';

my $local_tmpl="/mnt/data/web/dev/romanes2.com/templates/";

$out_dir="./";

if (length($lang_param)==2) {
    $lang_param = "_".$lang_param;
} else {
    $lang_param='';
}

# Header
my $header_content;
open(FIC,"$local_tmpl/header$lang_param.tmpl.html")||die "File ot found: $!\n";
while(<FIC>) {
    $header_content.=$_;
}
close(FIC);


# Footer
my $footer_content;
open(FIC,"$local_tmpl/footer$lang_param.tmpl.html")||die "File ot found: $!\n";
while(<FIC>) {
    $footer_content.=$_;
}


# Side
my $side_content;
open(FIC,"$local_tmpl/side$lang_param.tmpl.html")||die "File ot found: $!\n";
while(<FIC>) {
    $side_content.=$_;
}
close(FIC);

# Middle
my $middle_content;
open(FIC,"$local_tmpl/middle$lang_param.tmpl.html")||die "File ot found: $!\n";
while(<FIC>) {
    $middle_content.=$_;
}
close(FIC);

# End
my $end_content;
open(FIC,"$local_tmpl/end$lang_param.tmpl.html")||die "File ot found: $file_in $!\n";
while(<FIC>) {
    $end_content.=$_;
}
close(FIC);

# Content
my $file_content;
open(FIC,$file_in)||die "File ot found: $file_in $!\n";
print STDERR "Designing $file_in ";
while(<FIC>) {
    $file_content.=$_;
}
close(FIC);


# Save File
open  FIC,">".$out_dir.$file_out;
print FIC $header_content;
print FIC $side_content;
print FIC $middle_content;
print FIC $file_content;
print FIC $end_content;
print FIC $footer_content;
close(FIC);
print STDERR "Ok\n";

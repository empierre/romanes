#!/usr/bin/perl

open(FIC,$ARGV[0]);
<FIC>;#Skip first
while(<FIC>){

	chomp;
	my ($id,$group,$Editeur,$Collection,$Lang,$Titre,$Auteur,$Year,$ISBN,$img,$url)=split(/;/);

	$Editeur=~s/'/\\'/g;
	$Collection=~s/'/\\'/g;
	$Titre=~s/'/\\'/g;
	$Auteur=~s/'/\\'/g;
    if (! $Year) {$Year='null'};
    if (! $Auteur) {$Auteur='null'};

    next if (! $Editeur);

	my $out="INSERT INTO book (id,groupe,editor,collection,author,title,lang,year,isbn,url,url_picture) VALUES ($id,\'$group\',\'$Editeur\',\'$Collection\',\'$Auteur\',\'$Titre\',\'$Lang\',$Year,\'$ISBN\',\'$url\',\'$img\');\n";

	

	$out=~s/\x82/\&eacute;/g;
	$out=~s/\x8a/\&egrave;/g;
	$out=~s/\x0d//g;
	$out=~s/"//g;
	print $out;
	
};
close(FIC);

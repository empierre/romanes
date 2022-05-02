#!/usr/bin/perl
#
# $Log$
# Revision 1.3  1999/01/01 19:27:09  epierre
# adding english comments
#
# (c) 2001 Emmanuel PIERRE
#          epierre@e-nef.com
#          http://www.e-nef.com/users/epierre

use lib qw (/usr/local/etc/httpd/sites/e-nef.com/htdocs/cgibin/);
use strict;
use HTML::Template qw();


# File Open
#
my $id;
while($id=<*.jpg>) {
	chomp($id);
	my $newid=$id;
	$newid =~ s/�/e/g;
	$newid =~ s/�/e/g;
	$newid =~ s/�/e/g;
	$newid =~ s/\ /\\ /g;
	$newid =~ s/\ /_/g;
	$id =~ s/\ /\\ /g;
	if ($id ne $newid) {
		print $id."-".$newid."\n";
		`mv $id $newid`;
	}

}
close(IDX);

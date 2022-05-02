#!/usr/bin/perl

print "<html>\n<head><link href=\"http://www.romanes.com/css/styles2.css\" rel=\"stylesheet\" type=\"text/css\"></head><body class=\"divboxtext\">\n<table width=\"100%\">";
print "<tr><td width=\"40%\"></td><td width=\"20%\"></td><td width=\"40%\"></td></tr>\n";

open(FIC,"01-history.txt");
while(<FIC>) {
	chomp;
	if (! /;/) {
		print "<tr><td colspan=\"3\">&nbsp;</td></tr>\n";
		print "<tr><td colspan=\"3\" class=\"divboxtext\"><h2>$_è siècle</h2></td></tr>\n";
	} else {
		my @tab=split(/;/);
		print "<tr><td class=\"divboxtext\">".$tab[1]."</td>";
		print "<td class=\"divboxtext\"><center><b>".$tab[0]."</b></center></td>";
		print "<td class=\"divboxtext\">".$tab[2]."<br/>".$tab[3]."</td></tr>\n";
	}
}
close(FIC);

print "</table></body></html>\n";

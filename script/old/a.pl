#!/bin/perl
use Getopt::Std;

#print "-$result-\n";
#print "-$album-\n";
my %opts;
getopt('a', \%opts);
if ($opts{'a'}) {
	print $opts{'a'}."-\n";
	for (my $i=0;$i<=$#ARGV;$i++) {
		print "$i-".$ARGV[$i]."-\n";
	}
}

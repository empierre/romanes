#!/usr/bin/perl
my $version="0.1";

use Date::Manip;
use Getopt::Std;
use Fcntl;
use NDBM_File;
use strict;

# Global Variable Definitions
my $TZ='GMT';
$Date::Manip::TZ="GMT";
my $timestamp=time;
my %month=(
 'Jan' => '01',
 'Feb' => '02',
 'Mar' => '03',
 'Apr' => '04',
 'May' => '05',
 'Jun' => '06',
 'Jul' => '07',
 'Aug' => '08',
 'Sep' => '09',
 'Oct' => '10',
 'Nov' => '11',
 'Dec' => '12');

#
# Command Line Options Analysis
#

my %opts;
getopt('a', \%opts);
if ($opts{'V'}) {
    print "Romanes2 Generator v$version\n";
    exit 64;
}
if ($opts{'h'}) {
    &show_usage;
    exit 64;
}


if ($opts{'i'}) {
    `./make-index.sh`;
    exit 64;
}

if ($opts{'l'}) {
    `./make-index.sh`;
    `./make-all.sh`;
    exit 64;
}

if (length($ARGV[0])<1) {
    &show_usage;
    exit 64;
}

#
# Multi Input File
#
my (@VAFIC,@VDFIC);

#for (my $i=0;$i<=$#ARGV;$i++) {
#    my ($type,$fname)=split(/:/,$ARGV[$i]);
#    if ($type eq 'VA') {
#        push @VAFIC,$fname;
#    } elsif ($type eq 'VD') {
#        push @VDFIC,$fname;
#    } else {
#        print STDERR "BAD FILE NAME: $ARGV[$i]\n";
#        print STDERR "Aborting...\n";
#        exit;
#    }
#}




######################################################################
#
# Close files handles and exit
#

print STDERR"Ok\nDone.";

exit;

sub show_usage {
    print "Romanes2 Generator v$version\n";
    print "Usage:\n";
    print "\tr2m.pl [options] \n";
    print "\n";
    print "Options:\n\n";
    print "\t-a <place_id>\t\tAdd site from <place_id>\n";
    print "\t-p <album_id>\t\tPublish site <album_id>\n";
    print "\t-i \t\t\tGenerate index and transverse files\n";
    print "\t-l \t\t\tGenerate all albums\n";
    print "\n";
}



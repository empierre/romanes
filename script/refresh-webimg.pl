#!/usr/bin/perl
#
# Refresh the whole album data - backward compatibility
#
#
# version:0.99
#

# Get command line parameter
my $album_id=$ARGV[0];
my $out_dir=$ARGV[1];

system("cd $out_dir");
system("~/prod/r2/script/make-webimage2.pl $album_id $out_dir");
system("cp web/* ~/prod/r2/media/");
system("cd ..");

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

system("~/prod/r2/script/refresh-album.pl $album_id $out_dir");
system("~/prod/r2/script/refresh-img2.pl $album_id $out_dir");
system("~/prod/r2/script/refresh-sernum.pl $album_id $out_dir");
system("~/prod/r2/script/refresh-link2.pl $album_id $out_dir");

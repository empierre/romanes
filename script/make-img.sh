#!/bin/sh
chmod -x *.jpg
~/prod/r2/script/make-exif-name2.pl 
perl ./makename.pl
ls *.jpg >> images.idx
~/prod/r2/script/make-webimage2.pl 2&>1 &
~/prod/r2/script/make-thumb.pl
cd thumb;jpegoptim --strip-all -m65 --all-progressive *.jpg;cd ..
cd web; jpegoptim --strip-all -m65 --all-progressive *.jpg;cd ..
cp web/* ~/prod/r2/media
cp thumb/* ~/prod/r2/media/thumb


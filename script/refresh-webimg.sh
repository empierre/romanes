#!/bin/bash 
cd $2
~/prod/r2/script/make-webimage2.pl
cd web;jpegoptim --strip-all -m65 --all-progressive *.jpg;cd ..
cp web/* ~/prod/r2/media/
cd ..


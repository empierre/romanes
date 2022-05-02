#!/bin/sh
chmod -x *.jpg
convert $1 -resize 600x450 ../$1
jpegoptim --strip-all -m65 --all-progressive *.jpg


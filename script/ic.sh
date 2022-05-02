#!/bin/sh

iconv -f ISO-8859-1 -t UTF-8 photo.idx -o p.idx
iconv -f ISO-8859-1 -t UTF-8 album.idx -o a.idx
iconv -f ISO-8859-1 -t UTF-8 links.idx -o l.idx
iconv -f ISO-8859-1 -t UTF-8 images.idx -o i.idx
mv p.idx photo.idx
mv a.idx album.idx
mv l.idx links.idx
mv i.idx images.idx 

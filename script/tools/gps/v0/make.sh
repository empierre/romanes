#!/bin/sh

./make-place-asc.pl > Art_Roman_Eu.asc
./asc2kml.pl Art_Roman_Eu.asc >  Art_Roman_Eu.kml
./merge_ttpoi.pl -f r2.poi 

zip Art_Roman_Eu.zip Art_Roman_Eu.asc Art_Roman_Eu.bmp Art_Roman_Eu.ov2 Art_Roman_Eu.kml Art_Roman_Eu_m.ov2

#!/bin/bash

sudo apt install imagemagick libimage-exiftool-perl libimage-info-perl libimage-magick-perl libdigest-md5-file-perl libtext-unidecode-perl libdbd-mysql-perl libhtml-template-perl mariadb-server

cpan -f -i CPAN Image::Info Term::ReadLine::Perl Text::Unaccent::PurePerl Date::Manip

create database ROMANES3;
CREATE USER 'r2'@localhost IDENTIFIED BY 'romanes';
GRANT USAGE ON *.* TO 'r2'@localhost IDENTIFIED BY 'romanes';
GRANT ALL ON `ROMANES3`.* TO 'r2'@localhost;

mysql --user root -D ROMANES3  --force < r3.sql 

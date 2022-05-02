#!/usr/bin/perl -w
#
# create_ttpoi.pl
#
# Laurent Licour
# v1.1 18/09/05
# http://www.licour.com/gps/create_ttpoi/create_ttpoi.htm
#
# This software let create POI.DAT file for Tomtom Navigator from ov2 files source
#
# Attention : compte tenu du copyright existant sur les données utilisées par ce programme,
# ce dernier ne doit pas etre utilisé autrement que pour des fins personnel et experimental.
# Toute reutilsiation et/ou redistribution des données collectées irait a l'encontre du copyright
# des données, et est donc interdite.


use strict;
use Getopt::Long;
use IO;
use Data::Dumper;

my ($file_poidat, $file_lst);
my ($version, $help);
my (@IdCat, @FileCat);
my $NbCat;
my $verbose = 0;
my $TypeAlgo = 1;


my $NbMaxPOI = 10;


##########################
# Read LST file
##########################
sub read_lst
{
	my $NbCat = 0;
	
	open LST, "< $file_lst" or die ("Unable to open $file_lst");
	while(my $l=<LST>)
	{
		chop $l if (! eof(LST));
		next if ($l =~ /^\s*#/);			# comment
		next if ($l =~ /^\s*$/);			# empty line
		die "Bad format ($l)" if ($l !~ /^\s*\d+\s*=\s*.+\s*$/);
		
		$l =~ /^\s*(\d+)\s*=\s*(.+)\s*$/;
		my $id=$1;
		my $file=$2;
		die "The file $file does not exist ($l)" if (! -f "$file");
		$NbCat++;
		push (@IdCat, $id);
		push (@FileCat, $file);
		print "Found $file (ID $id)\n" if ($verbose);
	}
	close LST;
	
	return $NbCat;
}


##########################
# Write POI.DAT file
##########################
sub write_poidat
{

	print "Creating $file_poidat file...\n" if ($verbose);
	
	open POI, "> $file_poidat" or die("Unable to create $file_poidat");
	my $offset=0;
	my $data;

	# Categories number 
	$data = pack("V", $NbCat);
	syswrite POI, $data, 4;
	$offset += 4;

	# Categories ID table
	for(my $i=0; $i<$NbCat; $i++)
	{
		$data = pack("V", $IdCat[$i]);
		syswrite POI, $data, 4;
		$offset += 4;
	}

	# offset table
	for(my $i=0; $i<$NbCat; $i++)
	{
		my $len = -s "$FileCat[$i]";
		$data = pack("V", ($offset + ($NbCat+1)*4));
		syswrite POI, $data, 4;
		$offset += $len;
	}
	$data = pack("V", ($offset + ($NbCat+1)*4));
	syswrite POI, $data, 4;

	# files table
	for(my $i=0; $i<$NbCat; $i++)
	{
		my $filename = "$FileCat[$i]";
		my $len = -s "$filename";
	  open FH, "< $filename" or die("Error : unable to read $filename"); 
	  binmode FH;
	  read FH,$data,$len;
	  close FH;
		syswrite POI, $data, $len;
	}

	close POI;
	
	print "$file_poidat successfully created !\n" if ($verbose);
}


#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function return the string without heading and trailing spaces :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub trim {
 my $string = shift(@_);
 $string =~ s/^\s*(.*?)\s*$/$1/;
 return $string;
}


######################
# Read asc file
######################
sub read_asc
{
  my ($file) = @_;

  my @asc;

  open FH, "< $file" or warn("Error : unable to read $file\n") && return; 
  my $line=0;

  while(my $data=<FH>)
  { 
    $line++;
    chomp($data);
    $data = trim($data);
    next if (($data =~ /^;/) || ($data =~ /^$/));

    # Found POI
    # There is some approximations when converting values into float
    # so we process them as string
    if ($data =~ /^(-?\d+)\.(\d{5})\s*,\s*(-?\d+)\.(\d{5})\s*,\s*\"(.*)\"$/)
    {
    	my $x = "$1$2";
    	my $y = "$3$4";
    	my $d=$5;

      my $poi = { x => $x, y => $y, d => $d };
      push @asc, $poi;
    }
    else 
    {
      print "Unknown poi type format line $line. Abort !!\n";
      exit(1);
    }
  }
	close FH;

  return(@asc);
}

######################
# Read ov2 file
######################
sub read_ov2
{
  my ($file) = @_;

  my @ov2;
  
  open FH, "< $file" or warn("Error : unable to read $file\n") && return; 
  binmode FH;

  while(!eof(FH))
  {
    my $data;
    read FH,$data,1;

    # Type 0 record (deleted record)
    if ($data eq "\x00")
    {
      read FH, $data, 4;
      my $length=unpack("V", $data);
      read FH, $data, $length-5;
      next;
    }
    elsif ($data eq "\x01")
    # Type 1 record (proprietary content)
    {
      read FH, $data, 20;
      next;
    }
    elsif ($data eq "\x02")
    # Type 2 record (Simple POI)
    { 
      my $desc;
      read FH, $data, 4;
      my $length=unpack("V", $data);
      read FH, $data, 4;
      my $x=unpack("i", $data);
      read FH, $data, 4;
      my $y=unpack("i", $data);
      read FH, $desc, $length-14;
      read FH, $data, 1;

      my $poi = { x => $x, y => $y, d => $desc };
      push @ov2, $poi;
      next;
    }
    elsif ($data eq "\x03")
    # Type 3 record (Extended POI)
    {
      read FH, $data, 4;
      my $length=unpack("V", $data);
      read FH, $data, $length-5;
      next;
    }
    else
    {
      print "Unknown ov2 Type record. Abort !!\n";
      exit(1);
    }
  }

  close(FH);
  
  return(@ov2);
}



######################
# Encode individual POI
######################
sub encode_pois_02
{
	my ($ov2ref) = @_;
	my @ov2 = @$ov2ref;
	
	my $data = "";
	foreach my $poi (@ov2)
	{
		$data .= "\x02";
		
		$data .= pack("V", length($$poi{d}) + 13);
		
		$data .= pack("V", $$poi{x});
		
		$data .= pack("V", $$poi{y});
		
		$data .= $$poi{d};
	}
	
	return $data;
}

######################
# Encode individual POI
######################
sub encode_pois
{
	my ($ov2ref) = @_;
	my @ov2 = @$ov2ref;
	
	my $data = "";
	foreach my $poi (@ov2)
	{
		$data .= "\x07";
		
		$data .= pack("C", length($$poi{d}));
		
		my $x = $$poi{x} + 8000000;
		while ($x < 0)
		{
			$x += 8000000;
		}
		$data .= substr(pack("V", $x), 0, 3);
		
		$data .= substr(pack("V", $$poi{y} + 8000000), 0, 3);
		
		$data .= $$poi{d};
	}
	
	return $data;
}




my $pi = atan2(1,1) * 4;

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function return the distance between 2 points                     :::
#:::  Passed to function:                                                    :::
#:::    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)  :::
#:::    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)  :::
#:::    unit = the unit you desire for results                               :::
#:::           where: 'M' is statute miles (default)                         :::
#:::                  'K' is kilometers                                      :::
#:::                  'N' is nautical miles                                  :::
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub distance {
  my ($lat1, $lon1, $lat2, $lon2, $unit) = @_;
  
  if (($lat1 == $lat2) && ($lon1 == $lon2))
  {
    return(0);
  }
  my $theta = $lon1 - $lon2;
  my $dist = sin(deg2rad($lat1)) * sin(deg2rad($lat2)) + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * cos(deg2rad($theta));
  $dist  = acos($dist);
  $dist = rad2deg($dist);
  $dist = $dist * 60 * 1.1515;
  if ($unit eq "K") {
  	$dist = $dist * 1.609344;
  } elsif ($unit eq "N") {
  	$dist = $dist * 0.8684;
		}
  return ($dist);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function get the arccos function using arctan function   :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub acos {
	my ($rad) = @_;
	my $ret = atan2(sqrt(1 - $rad**2), $rad);
	return $ret;
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts decimal degrees to radians             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub deg2rad {
	my ($deg) = @_;
	return ($deg * $pi / 180);
}

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function converts radians to decimal degrees             :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub rad2deg {
	my ($rad) = @_;
	return ($rad * 180 / $pi);
}

sub process_basic_division_old
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;
	
	# We have to divide these POIs
	my $nb_x_division = 2;
	my $nb_y_division = 1;
		
	
	my @lst_ov2;		# List of structures of sub aera

	# Find arbitrary edge : divide aera in several zones 
	my $xdist = abs ( ($$square{x2} - $$square{x1}) / $nb_x_division );		# "size" of each X subdivision
	my $ydist = abs ( ($$square{y2} - $$square{y1}) / $nb_y_division );		# "size" of each Y subdivision

	for(my $i=0; $i<$nb_x_division; $i++)
	{
		for(my $j=0; $j<$nb_y_division; $j++)
		{
			# compute limit of the aera
			my $x_low_limit   = $$square{x1} + $xdist*$i;
			my $x_upper_limit = $$square{x1} + $xdist*($i+1);
			$x_upper_limit++ if ($i == $nb_x_division-1);

			my $y_low_limit   = $$square{y1} + $ydist*$j;
			my $y_upper_limit = $$square{y1} + $ydist*($j+1);
			$y_upper_limit++ if ($j == $nb_y_division-1);

			# do the division
			my @ov2_extract = grep { ($$_{x} >=  $x_low_limit) && ($$_{x} <  $x_upper_limit) && ($$_{y} >=  $y_low_limit) && ($$_{y} <  $y_upper_limit)} @ov2;				# extract poi

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
				my $sq_extract = get_square(\@ov2_extract);
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
	
	# job is finished. Returns sub-division
	return @lst_ov2;
}

sub process_basic2_division_old
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;
	
	# We have to divide these POIs
	my $nb_x_division = 2;
	my $nb_y_division = 1;
		
	
	my @lst_ov2;		# List of structures of sub aera

	# Find arbitrary edge : divide aera in several zones 
	my $xdist = abs ( ($$square{x2} - $$square{x1}) / $nb_x_division );		# "size" of each X subdivision
	my $ydist = abs ( ($$square{y2} - $$square{y1}) / $nb_y_division );		# "size" of each Y subdivision

	for(my $i=0; $i<$nb_x_division; $i++)
	{
		for(my $j=0; $j<$nb_y_division; $j++)
		{
			# compute limit of the aera
			my $x_low_limit   = $$square{x1} + $xdist*$i;
			my $x_upper_limit = $$square{x1} + $xdist*($i+1);
			$x_upper_limit=$$square{x2} if ($i == $nb_x_division-1);

			my $y_low_limit   = $$square{y1} + $ydist*$j;
			my $y_upper_limit = $$square{y1} + $ydist*($j+1);
			$y_upper_limit=$$square{y2} if ($j == $nb_y_division-1);

			# do the division
			my @ov2_extract = grep { ($$_{x} >=  $x_low_limit) && ($$_{x} <  $x_upper_limit) && ($$_{y} >=  $y_low_limit) && ($$_{y} <  $y_upper_limit)} @ov2;				# extract poi

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract={ x1 => $x_low_limit, y1 => $y_low_limit, x2 => $x_upper_limit, y2 => $y_upper_limit };
#				my $sq_extract = get_square(\@ov2_extract);
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
	
	# job is finished. Returns sub-division
	return @lst_ov2;
}

############################################
# Division Algo : based on equal aera division
# each parent-aera is divide in several child-aera, of the same size
# Each child aera contains variables POIs number, due to POI density
# in this area
# We divide parent aera in n=x*y child aera
# This seems to be equivalent that makeov2
############################################
sub process_basic_division_geo
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;
	
	# We have to divide these POIs
	my $nb_x_division = 2;
	my $nb_y_division = 2;
		
	
	my @lst_ov2;		# List of structures of sub aera

	# Find arbitrary edge : divide aera in several zones 
	my $xdist = abs ( ($$square{x2} - $$square{x1}) / $nb_x_division );		# "size" of each X subdivision
	my $ydist = abs ( ($$square{y2} - $$square{y1}) / $nb_y_division );		# "size" of each Y subdivision

	if ($xdist > $ydist)
	{
		for(my $i=0; $i<$nb_x_division; $i++)
		{
			my $x_low_limit   = int($$square{x1} + $xdist*$i);
			my $x_upper_limit = int($$square{x1} + $xdist*($i+1));
			$x_upper_limit=$$square{x2}+1 if ($i == $nb_x_division-1);		# Add 1 to handle -lt in grep

			# do the division
			my @ov2_extract = grep { ($$_{x} >=  $x_low_limit) && ($$_{x} <  $x_upper_limit) } @ov2;				# extract poi

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract={ x1 => $x_low_limit, y1 => $$square{y1}, x2 => $x_upper_limit, y2 => $$square{y2} };
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
	else
	{
		for(my $j=0; $j<$nb_y_division; $j++)
		{
			# compute limit of the aera
			my $y_low_limit   = int($$square{y1} + $ydist*$j);
			my $y_upper_limit = int($$square{y1} + $ydist*($j+1));
			$y_upper_limit=$$square{y2}+1 if ($j == $nb_y_division-1);

			# do the division
			my @ov2_extract = grep { ($$_{y} >=  $y_low_limit) && ($$_{y} <  $y_upper_limit) } @ov2;				# extract poi

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract={ x1 => $$square{x1}, y1 => $y_low_limit, x2 => $$square{x2}, y2 => $y_upper_limit };
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
		
	# job is finished. Returns sub-division
	return @lst_ov2;
}


############################################
# Division Algo : based on POI repartition
# the division is made by getting coord of upper and lower POI
# so this create holes in record 01
# It seems to work, but could be too aggressive for Tomtom
############################################
sub process_basic_division_nbpoi_aggressive
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;
	
	# We have to divide these POIs
	my $nb_x_division = 2;
	my $nb_y_division = 2;
		
	
	my @lst_ov2;		# List of structures of sub aera

	# Find arbitrary edge : divide aera in several zones 
	my $xdist = abs ( ($$square{x2} - $$square{x1}) / $nb_x_division );		# "size" of each X subdivision
	my $ydist = abs ( ($$square{y2} - $$square{y1}) / $nb_y_division );		# "size" of each Y subdivision


	# on decoupe horizontalement ou verticalement, par alternance	
	if ($xdist > $ydist)
	{
		my $poi_per_x = int(($#ov2 + 1) / $nb_x_division);

		# Tri des POIs
		my @ov2_sorted = sort( {$$a{x} <=> $$b{x}} @ov2);			
		
		for(my $i=0; $i<$nb_x_division; $i++)
		{
			my $low_indice = $i * $poi_per_x;
			my $high_indice = (($i+1) * $poi_per_x) - 1;
			$high_indice=$#ov2 if ($i == $nb_x_division-1);

		
			# do the division
			my @ov2_extract = @ov2_sorted[$low_indice..$high_indice];
			
			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract=get_square(\@ov2_extract);
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
	else
	{
		my $poi_per_y = int(($#ov2 + 1) / $nb_y_division);
		my @ov2_sorted = sort( {$$a{y} <=> $$b{y}} @ov2);			
		
		for(my $i=0; $i<$nb_y_division; $i++)
		{
			my $low_indice = $i * $poi_per_y;
			my $high_indice = (($i+1) * $poi_per_y) - 1;
			$high_indice=$#ov2 if ($i == $nb_y_division-1);
			
			
			# do the division
			my @ov2_extract = @ov2_sorted[$low_indice..$high_indice];

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract=get_square(\@ov2_extract);
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}

	# job is finished. Returns sub-division
	return @lst_ov2;
}


############################################
# Division Algo : based on POI repartition
# The division is made by divide parent square into several pieces
# so the algo seems to be more realistic from the original algo from tomtom
############################################
sub process_basic_division_nbpoi_experimental
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;
	
	# We have to divide these POIs
	my $nb_x_division = 2;
	my $nb_y_division = 2;
		
	
	my @lst_ov2;		# List of structures of sub aera

	# Find arbitrary edge : divide aera in several zones 
	my $xdist = abs ( ($$square{x2} - $$square{x1}) / $nb_x_division );		# "size" of each X subdivision
	my $ydist = abs ( ($$square{y2} - $$square{y1}) / $nb_y_division );		# "size" of each Y subdivision


	# on decoupe horizontalement ou verticalement, par alternance	
	if ($xdist > $ydist)
	{
		my $poi_per_x = int(($#ov2 + 1) / $nb_x_division);

		my @ov2_sorted = sort( {$$a{x} <=> $$b{x}} @ov2);			
		

		for(my $i=0; $i<$nb_x_division; $i++)
		{
			my $low_indice = $i * $poi_per_x;
			my $high_indice = (($i+1) * $poi_per_x) - 1;
			$high_indice=$#ov2 if ($i == $nb_x_division-1);

			my $x_low_limit;
			my $x_upper_limit;

			# Get the low limit of the aera
			if ($i == 0)
			{
				$x_low_limit=$$square{x1};
			}
			else
			{
				my $previous_indice = $low_indice - 1;
				my $previous_poi = $ov2_sorted[$previous_indice];
				$x_low_limit = $$previous_poi{x};
			}
			
			# Get the Upper limit of the aera
			if ($i == $nb_x_division-1)
			{
				$x_upper_limit=$$square{x2};
			}
			else
			{
				my $last_poi  = $ov2_sorted[$high_indice];
				$x_upper_limit = $$last_poi{x};
			}
			
		
			# do the division
			my @ov2_extract = @ov2_sorted[$low_indice..$high_indice];
			
			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract={ x1 => $x_low_limit, y1 => $$square{y1}, x2 => $x_upper_limit, y2 => $$square{y2} };
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}
	else
	{
		my $poi_per_y = int(($#ov2 + 1) / $nb_y_division);

		# Tri des POIs
		my @ov2_sorted = sort( {$$a{y} <=> $$b{y}} @ov2);			
		
		for(my $i=0; $i<$nb_y_division; $i++)
		{
			my $low_indice = $i * $poi_per_y;
			my $high_indice = (($i+1) * $poi_per_y) - 1;
			$high_indice=$#ov2 if ($i == $nb_y_division-1);
			
			my $y_low_limit;
			my $y_upper_limit;

			# Get the low limit of the aera
			if ($i == 0)
			{
				$y_low_limit=$$square{y1};
			}
			else
			{
				my $previous_indice = $low_indice - 1;
				my $previous_poi = $ov2_sorted[$previous_indice];
				$y_low_limit = $$previous_poi{y};
			}
			
			# Get the Upper limit of the aera
			if ($i == $nb_y_division-1)
			{
				$y_upper_limit=$$square{y2};
			}
			else
			{
				my $last_poi  = $ov2_sorted[$high_indice];
				$y_upper_limit = $$last_poi{y};
			}
			
			
			# do the division
			my @ov2_extract = @ov2_sorted[$low_indice..$high_indice];

			# there is POIs in this child-aera
			if ($#ov2_extract >= 0)
			{
				# build a structure that contains child aera
			  my $sq_extract={ x1 => $$square{x1}, y1 => $y_low_limit, x2 => $$square{x2}, y2 => $y_upper_limit };
				my $sub_ov2 = {square => $sq_extract, ov2 => [ @ov2_extract ] };
				push (@lst_ov2, $sub_ov2);
			}
		}
	}

	# job is finished. Returns sub-division
	return @lst_ov2;
}

############################################
# divide parent area into child area
############################################
sub divide
{
	my ($ov2ref, $square) = @_;
	my @ov2 = @$ov2ref;

	my $all_data = "";

	# All POIs are in the same km² : no more division possible
	my $lon1 = $$square{x1};
	my $lon2 = $$square{x2};
	my $lat1 = $$square{y1};
	my $lat2 = $$square{y2};
  my $dist1 = distance($lon2/100000, $lat2/100000, $lon2/100000, $lat1/100000, "K");
  my $dist2 = distance($lon2/100000, $lat2/100000, $lon1/100000, $lat2/100000, "K");
  if ($dist1*$dist2 < 1)
  {  
		# encodage des POIS
		my $data = encode_pois (\@ov2);
		return $data;
	}

	# Max number of POIs per Record 01
	if ($#ov2 < $NbMaxPOI)
	{
		# encodage des POIS
		my $data = encode_pois (\@ov2);
		return $data;
	}
	

	my @lst_ov2;
	@lst_ov2 = process_basic_division_nbpoi_experimental(\@ov2, $square) if ($TypeAlgo == 1);
	@lst_ov2 = process_basic_division_geo(\@ov2, $square)   if ($TypeAlgo == 2);
	@lst_ov2 = process_basic_division_nbpoi_aggressive(\@ov2, $square) if ($TypeAlgo == 3);
	
	undef @ov2;			# we don't need any more parent datas
		
	# and now, sub-divide each aera
	foreach my $st_ov2 (@lst_ov2)
	{
		# get element
		my $sq = $$st_ov2{square};
		my $ref_ov2 = @$st_ov2{ov2};		# pointeur sur tableau de OV2 dans la structure
		my @my_ov2 = @$ref_ov2;
			
		return "" if ($#my_ov2 == -1);			# there is no POI in this sub-aera

		# Recursive call		
		my $data = divide(\@my_ov2, $sq);
		$all_data .= encode_record01($data, $sq) . $data;
	}

  return $all_data;
}

####################################################
# Compute upper and lower limite of the aera
#####################################################
sub get_square
{
  my ($lst) = @_;
  
  my $x1= 36000000;
  my $y1= 36000000;
  my $x2=-36000000;
  my $y2=-36000000;
  
	foreach my $poi (@$lst)
	{
		# min
		$x1=$$poi{x} if ($x1 > $$poi{x});
		$y1=$$poi{y} if ($y1 > $$poi{y});
		
		# max
		$x2=$$poi{x} if ($x2 < $$poi{x});
		$y2=$$poi{y} if ($y2 < $$poi{y});
	}
  
  my $square={ x1 => $x1, y1 => $y1, x2 => $x2, y2 => $y2 };
  return $square;
}


sub encode_record01
{
	my ($data, $square) = @_;
		
	# Record Type
	my $local_data = "\x01";
	
	# Record Length
	$local_data .= pack("V", length($data) + 21);
	
	# Record coord
	$local_data .= pack("V", $$square{x2});
	$local_data .= pack("V", $$square{y2});
	$local_data .= pack("V", $$square{x1});
	$local_data .= pack("V", $$square{y1});

  return $local_data;
}


##########################################################################################
# Routine de conversion d'un fichier POI au format OV2/ASC en un fromat "POI"
##########################################################################################
sub convert_poi
{
	my ($filename) = @_;

	$filename =~ /^(.*)\.(\w\w\w)$/;
	my $basename = $1;
	my $ext = $2;
	
	my $file_poi = "$basename.poi";
	
	my @ov2;
	if ($ext =~ /ov2/i)
	{
		# Read the first byte of OV2 file to identify if conversion is necessary
		open FOV2, "< $filename" or die "Unable to open $filename for reading";
  	binmode FOV2;
    my $data;
    read FOV2,$data,1;
    close FOV2;

#    # This is ever a Record 01 OV2 file (made with makeov2.exe)
#    if ($data eq "\x01")	
#    {		
#			print "Processing OV2 file as POI file ($filename)...\n" if ($verbose);
#			return $filename;
#		}
		
		print "Converting OV2 file to POI file ($filename)...\n" if ($verbose);
		@ov2 = read_ov2($filename);
	}
	else
	{
		print "Converting ASC file to POI file ($filename)...\n" if ($verbose);
		@ov2 = read_asc($filename);
	}
	
	open POI, "> $file_poi" or die "Unable to open $file_poi for writing";

	# Conversion des POIs
	my $square=get_square(\@ov2);
	my $data = divide(\@ov2, $square);

	$data = encode_record01($data, $square) . $data;

	syswrite POI, $data, length($data);
	close POI;
	
	return $file_poi;
}


my $ver = "create_ttpoi.pl v1.1 18/09/2005\n";
 
my $syntax = "syntax: $0 -i <poi.lst input file> -o <poi.dat output file> [-v]\n";
sub usage
{
	print $syntax;
  exit 1;
}


sub get_UniqueCatId
{
	my @UniqCat;
	
	foreach my $cat (@IdCat)
	{
		my @extract = grep(/^$cat$/, @UniqCat);
		push @UniqCat, $cat if ($#extract == -1);
	}

	return @UniqCat;
}

sub get_UniqueCat
{
	my ($Id) = @_;
	
	my @UniqCat;
	
	for(my $i=0; $i<$NbCat; $i++)
	{
		if ($IdCat[$i] == $Id)
		{
			push @UniqCat, $FileCat[$i];
		}
	}
		
	return @UniqCat;
}



Getopt::Long::GetOptions(
   "o=s" => \$file_poidat,
   "i=s" => \$file_lst,
   "h" => \$help,
   "v" => \$verbose,
   "a=i" => \$TypeAlgo,
   "n=i" => \$NbMaxPOI
   ) or die $syntax;

usage if $help;
die $ver if $version;
die $syntax unless @ARGV == 0;
die $syntax unless defined($file_poidat);
die $syntax unless defined($file_lst);
die $syntax unless ($TypeAlgo =~ /^[123]$/);

$NbCat = read_lst();

my @UniqCat = get_UniqueCatId;

print "-> " . ($#UniqCat+1) . " Uniq Categories Found ($NbCat files)\n" if ($verbose);
die "No categorie found in $file_lst file" if ($NbCat == 0);

my (@ID, @FILE);

# Boucle sur chaque categorie unique
for(my $i=0; $i<$#UniqCat+1; $i++)
{
	print "Processing Category $UniqCat[$i]\n" if ($verbose);
	
	# Recup de la liste des fichiers constituant la categorie
	my @LstUniqCat = get_UniqueCat($UniqCat[$i]);
	
	# Un seul fichier : traitement direct
	if ($#LstUniqCat == 0)
	{
		my $filename = $LstUniqCat[0];
		$filename =~ /\.(\w\w\w)$/;
		my $ext = $1;
		die "Unknown extension format for $filename" unless ($ext =~ /(asc)|(ov2)|(poi)/i);
	
		# Convert ASC/OV2 file to POI file format
		$LstUniqCat[0] = convert_poi($filename) if ($ext =~ /(asc)|(ov2)/i);
	}
	# Plusieurs fichiers : concatenation en fichier OV2
	else
	{
		my @GlobPOI;
		foreach my $filename (@LstUniqCat)
		{
			$filename =~ /\.(\w\w\w)$/;
			my $ext = $1;
			die "Can't process POI file with additional file. Convert it to ASC or OV2" if ($ext =~ /poi/);
			die "Unknown extension format for $filename" unless ($ext =~ /(asc)|(ov2)/i);
			
			# Format POI non supporté, car necessite conversion en dechiffré
			push @GlobPOI, read_ov2($filename) if ($ext =~ /ov2/i);
			push @GlobPOI, read_asc($filename) if ($ext =~ /asc/i);
		}
		
		@LstUniqCat = ();
		my $filename = "$UniqCat[$i]_concat.ov2";
		
		print "Creating $filename\n" if ($verbose);
		# Creation fichier OV2 concatené
		open OV2, "> $filename" or die("Unable to create $filename");
		my $data = encode_pois_02 \@GlobPOI;
		syswrite OV2, $data, length($data);
		close OV2;
		
		$LstUniqCat[0] = convert_poi($filename);
		print "Converting to $LstUniqCat[0] done\n" if ($verbose);
	}
	
	push @ID, $UniqCat[$i];
	push @FILE, $LstUniqCat[0];
}

$NbCat = $#UniqCat+1;
@IdCat = @ID;
@FileCat = @FILE;

write_poidat();

exit 0;



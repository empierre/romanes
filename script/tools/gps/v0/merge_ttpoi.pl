#!/usr/bin/perl -w
#
# merge_ttpoi.pl
#
# Laurent Licour
# v1.0 30/04/04
# http://www.licour.com/gps/merge_ttpoi/merge_ttpoi.htm
#
# Ce programme permet de concatener des bases de POIs (fichiers tomtom navigator 2 & 3)
#

use strict;
use LWP::Simple;
use File::Path;
use File::Basename;
use Getopt::Long;
use URI;

# Default directory where to store downloaded files
my $dirpoi = "POIs\\";

# external program used to unzip file
my $unzip="unzip";


# Array that store all the POIs read
my @lst_poi;
my @lst_poi_except;

my $verbose=0;

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#:::  This function return the string without heading and trailing spaces :::
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
sub trim {
 my $string = shift(@_);
 $string =~ s/^\s*(.*?)\s*$/$1/;
 return $string;
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
  my ($poi1, $poi2, $unit) = @_;
  my %p1 = %{$poi1};
  my %p2 = %{$poi2};
  
  my $lat1 = $p1{'x'};
  my $lon1 = $p1{'y'};
  my $lat2 = $p2{'x'};
  my $lon2 = $p2{'y'};

  if (($lat1 == $lat2) && ($lon1 == $lon2))
  {
    return(0);
  }
  my $theta = $p1{'y'} - $p2{'y'};
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
      my $poi = { x => $x/100000, y => $y/100000, d => $desc };
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
# Save ov2 file
######################
sub save_ov2
{
  my ($file, @poi) = @_;

  open FH,"> $file" or die("Error : unable to write to $file\n");
  binmode FH;

  my $nb_save = 0;
  for(my $i=0; $i<=$#poi; $i++)
  {
    my $x = $poi[$i]{'x'} * 100000;
    my $y = $poi[$i]{'y'} * 100000;
    my $d = $poi[$i]{'d'};

    next if (($x eq 0) && ($y eq 0));

    $nb_save++;
    my $data;
    syswrite FH, "\x02", 1;
    $data = pack("V", length($d)+14);
    syswrite FH, $data, 4;
    $data = pack("i", $x);
    syswrite FH, $data, 4;
    $data = pack("i", $y);
    syswrite FH, $data, 4;
    syswrite FH, $d, length($d);
    syswrite FH, "\x00", 1;
  }
  
  close(FH);
  
  return $nb_save;
}

######################
# Read asc file
######################
sub read_asc
{
  my ($file) = @_;

  my @asc;
  print $file . "\n";
  open FH, "< $file" or warn("Error : unable to read $file\n") && return; 
  my $line=0;

  while(my $data=<FH>)
  { 
    $line++;
    chomp($data);
    $data = trim($data);
    next if (($data =~ /^;/) || ($data =~ /^$/));

    # Found POI
    if ($data =~ /^(-?\d+\.\d+) *, *(-?\d+\.\d+) *, *"(.*)"$/)
    {
      my $poi = { x => $1, y => $2, d => $3 };
      push @asc, $poi;
    }
    else 
    {
      print "Unknown poi type format line $line. Abort !!\n";
      exit(1);
    }
  }

  return(@asc);
}

######################
# Save asc file
######################
sub save_asc
{
  my ($file, @poi) = @_;

  open FH,"> $file" or die("Error : unable to write to $file\n");

  print FH "; Longitude,    Latitude, \"Name\"\n";
  print FH "; ========== ============ ==================================================\n";
  print FH "\n";

  my $nb_save = 0;
  for(my $i=0; $i<=$#poi; $i++)
  {
    my $x = $poi[$i]{'x'};
    my $y = $poi[$i]{'y'};
    my $d = $poi[$i]{'d'};

    next if (($x eq 0) && ($y eq 0));

    $nb_save++;
    my $data;
    print FH sprintf("%10.5f ,%11.5f , \"%s\"", $x, $y, $d) . "\n";
  }
  
  close(FH);
  
  return $nb_save;
}

################################################################
# Download a URL file to disk, and return local filename
################################################################
sub mod_getfile
{
  my ($line_url, $file) = @_;

  my $url = URI->new($line_url);
  my $dir;

  # this is a local file. No need to dowload it first  
  if ($url->scheme eq "file")
  {
    $$file = $url->opaque;
    
    # Transform back %20 to space
    $$file =~ s/%20/ /g;
    
    $dir = File::Basename::dirname($$file);
  }
  elsif ($url->scheme eq "http")
  {    
    # Where to store the file
    $$file = $dirpoi . $url->opaque;
    $dir = File::Basename::dirname($$file);
    File::Path::mkpath($dir);

    # download file, keeping time stamp.
    my $res = LWP::Simple::mirror($line_url, $$file);
    if (($res != 200) && ($res != 304))
    {
      print " Unable to download $line_url\n";
      if (-e $$file)
      {
        print " Use cached copy : $$file\n" if ($verbose);
      }
      else
      {
        return 1;
      }
    }
    elsif (($res == 304) && ($verbose))
    {
      print " (Not modified)\n";
    }
  }
  else
  {
    print " Don't know how to process $line_url\n";
    return 1;
  }

  return 0;
}

###########################################################################
# mod_getzip
#  param : url
#  description : download and unzip file
############################################################################

sub mod_getzip
{
  my ($line_url) = @_;
  my $file_zip;

  print "$line_url\n";
  print "=" x length($line_url);
  print "\n";

  # download file and get local file name
  mod_getfile($line_url, \$file_zip);
  
  system("$unzip -u -o -d " . File::Basename::dirname($file_zip) . " $file_zip "); 
  print "\n";
}


###########################################################################
# Module : getpoi
# Read POI file and fill memory array
#  param : type, mode, url
#  type :  asc | ov2
#  mode :  0 : don't store filename description, leave it as now
#          1 : store filename descritpion if empty in ov2 file
#          2 : store filename descritpion even if filled in ov2 file (replace mode)
#          3 : store filename descritpion even if filled in ov2 file (apend mode)
#          4 : clean description
############################################################################
sub mod_getpoi
{
  my ($type, $mode, $line_url) = @_;
  my $file_poi;

  print "$line_url\n";
  print "=" x length($line_url);
  print "\n";

  # download file and get local file name
  mod_getfile($line_url, \$file_poi);
  
  # read poi records
  my @poi;
  @poi = read_ov2($file_poi) if ($type =~ /ov2/);
  @poi = read_asc($file_poi) if ($type =~ /asc/);
  
  # get filename, no extension
  my $desc_file = File::Basename::basename($file_poi);
  $desc_file =~ s/^(.*)\..*/$1/;

  for(my $i=0; $i<=$#poi; $i++)
  {
    my $d = trim($poi[$i]{'d'});

    # get description of the poi
    my $desc = $d;
    $desc = $d             if ($mode eq 0);
    $desc = "<$desc_file>" if (($mode eq 1) && (trim($d) eq ""));
    $desc = "<$desc_file>" if ($mode eq 2);
    $desc = "$d | <$desc_file>" if ($mode eq 3);
    $desc = ""             if ($mode eq 4);
      
    # replace descrition of poi
    $poi[$i]{'d'} = $desc;
  }
  
  # Mode 5 : exception
  if ($mode eq 5)
  {
    print "  --> Read " . ($#poi + 1) . " POIs as Exceptions\n\n";
  }
  else
  {
    print "  --> Read " . ($#poi + 1) . " POIs\n\n";
  }       

  return @poi;
}

##########################################################
# Module : deldup
# delete duplicate POIs
#  param : radius, unit, array
#  radius : (integer)
#  unit : m (meters) or y (yards)
##########################################################
sub mod_deldup
{
  my ($radius, $unit, @poi_in) = @_;

  print "Delete duplicate points\n";
  print "=======================\n";
  
  print "Radius : $radius ";
  print "meters\n" if ($unit eq 'K');
  print "yards\n" if ($unit eq 'M');
  

  my @poi_tmp = @poi_in;
  
  my $nb_delete=0;
  
  for(my $i=0; $i<=$#poi_in; $i++)
  {
    my $x1 = $poi_tmp[$i]{'x'};
    my $y1 = $poi_tmp[$i]{'y'};
    next if (($x1 eq 0) && ($y1 eq 0));
    my $d1 = trim($poi_tmp[$i]{'d'});
    
    for(my $j=$i+1; $j<=$#poi_in; $j++)
    {
      my $x2 = $poi_tmp[$j]{'x'};
      my $y2 = $poi_tmp[$j]{'y'};
      next if (($x2 eq 0) && ($y2 eq 0));
      my $d2 = trim($poi_tmp[$j]{'d'});
  
      # compute distance between the 2 points
      my $dist =  int (distance($poi_tmp[$i], $poi_tmp[$j], $unit) * 1000);

      # these poi are seems to be equals
      if ($dist <= $radius)
      {
        if ($d1 eq $d2)
        {
          # mark poi to be deleted
          $poi_tmp[$j]{'x'} = 0;
          $poi_tmp[$j]{'y'} = 0;

          $nb_delete++;
        }
        elsif (($d1 =~ /^<.*>$/) && ($d2 =~ /^<.*>$/))
        # same point, differents descritions (no description from original file)
        {
          $d1 =~ s/^<(.*)>$/$1/;
          $d2 =~ s/^<(.*)>$/$1/;

          # replace descrition of first poi
          $poi_tmp[$i]{'d'} = "<$d1 | $d2>";
          
          # mark second poi to be deleted
          $poi_tmp[$j]{'x'} = 0;
          $poi_tmp[$j]{'y'} = 0;
          $nb_delete++;
        }
        else
        # same point, differents descriptions. Merge them
        {
          # replace descrition of first poi
          $poi_tmp[$i]{'d'} = "$d1 | $d2";
          
          # mark second poi to be deleted
          $poi_tmp[$j]{'x'} = 0;
          $poi_tmp[$j]{'y'} = 0;
          $nb_delete++;
        }
      }
  
    } # for($j
  } # for($i


  # and now, we have to delete POIs from list
  my @poi_out;

  # delete marked POIs
  for(my $i=0; $i<=$#poi_tmp; $i++)
  {
    my $x = $poi_tmp[$i]{'x'};
    my $y = $poi_tmp[$i]{'y'};
    if (($x != 0) || ($y != 0))
    {
      push @poi_out, $poi_tmp[$i];
    }
  }

  print "POIs processed   : " . ($#poi_in + 1) . "\n";
  print "POIs deleted     : " . $nb_delete . "\n";
  print "POIs to save     : " . ($#poi_out + 1) . "\n";
  print "\n";
  
  return(@poi_out);
}


##########################################################
# Module : deldup
# Delete execption POIs
#  param : radius, unit, array
#  radius : (integer)
#  unit : m (meters) or y (yards)
##########################################################
sub mod_delexcept
{
  my ($radius, $unit) = @_;

  print "Delete exception points\n";
  print "=======================\n";
  
  print "Radius : $radius ";
  print "meters\n" if ($unit eq 'K');
  print "yards\n" if ($unit eq 'M');
    
  my $nb_delete=0;
  
  for(my $i=0; $i<=$#lst_poi; $i++)
  {
    my $x1 = $lst_poi[$i]{'x'};
    my $y1 = $lst_poi[$i]{'y'};
    my $d1 = trim($lst_poi[$i]{'d'});
    
    for(my $j=0; $j<=$#lst_poi_except; $j++)
    {
      my $x2 = $lst_poi_except[$j]{'x'};
      my $y2 = $lst_poi_except[$j]{'y'};
      my $d2 = trim($lst_poi_except[$j]{'d'});

      # compute distance between the 2 points
      my $dist =  int (distance($lst_poi[$i], $lst_poi_except[$j], $unit) * 1000);

      # these poi are seems to be equals
      if ($dist <= $radius)
      {
        # mark poi to be deleted
        $lst_poi[$i]{'x'} = 0;
        $lst_poi[$i]{'y'} = 0;

        $nb_delete++;
        last;   #  exit $j loop
      }
    } # for($j
  } # for($i


  print "POIs to process   : " . ($#lst_poi + 1) . "\n";
  print "POIs of exception : " . ($#lst_poi_except + 1) . "\n";
  print "POIs deleted      : " . $nb_delete . "\n";
  print "POIs to save      : " . ($#lst_poi - $nb_delete + 1) . "\n";
  print "\n";
  
  return;
}

#############################################################
# Module : savestat
# Save or display statistics on length beetween POI 
#############################################################
sub mod_savestat
{
  my ($file, @dist_stats) = @_;

  if ($file =~ /^$/)
  {
    print "Display statistics\n";
    print "==================\n";
  }
  else
  {
    print "Save statistics to : $file\n";
    print "=====================";
    print "=" x length($file);
    print "\n";
  }
    
  # tableau de compteur   
  my %nb;

  for(my $i=0; $i<=$#dist_stats; $i+=2)
  {
    my $dist = $dist_stats[$i];
    my $unit = $dist_stats[$i+1];
    $nb{$dist.$unit} = 0;
  }

  
  for(my $i=0; $i<=$#lst_poi; $i++)
  {
    my $x1 = $lst_poi[$i]{'x'};
    my $y1 = $lst_poi[$i]{'y'};
    next if (($x1 eq 0) && ($y1 eq 0));
    my $d1 = trim($lst_poi[$i]{'d'});
    
    for(my $j=$i+1; $j<=$#lst_poi; $j++)
    {
      my $x2 = $lst_poi[$j]{'x'};
      my $y2 = $lst_poi[$j]{'y'};
      next if (($x2 eq 0) && ($y2 eq 0));
      my $d2 = trim($lst_poi[$j]{'d'});
  
      # compute distance between the 2 points (compute in meters and yards)
      my %my_dist;
      $my_dist{'y'} =  int (distance($lst_poi[$i], $lst_poi[$j], "M") * 1000);
      $my_dist{'m'} =  $my_dist{'y'} * 1.609344;

      for(my $k=0; $k<=$#dist_stats; $k+=2)
      {
        my $dist = $dist_stats[$k];
        my $unit = $dist_stats[$k+1];
        $nb{$dist.$unit}++ if ($my_dist{$unit} <= $dist);
      } # for($k
    } # for($j
  } # for($i


  my $res_stat;
  $res_stat .= "Nb points : " . ($#lst_poi + 1) . "\n";
  
  for(my $i=0; $i<=$#dist_stats; $i+=2)
  {
    my $dist = $dist_stats[$i];
    my $unit = $dist_stats[$i+1];
    $res_stat .= " < " . sprintf("%5d", $dist) . $unit . " : " . $nb{$dist.$unit} . "\n";
  }

  if ($file =~ /^$/)
  {
    print $res_stat;
  }
  else
  {
    # display statistics
    open(FILE_STAT, ">$file") or die("Unable to open $file"); 
    print FILE_STAT "Distance Statistics\n";
    print FILE_STAT "===================\n";
    print FILE_STAT $res_stat;
    close(FILE_STAT);
  }

  print "\n";

  return();
}

#############################################
# Module : savepoi
# Save POIs to a file in specific format
#############################################
sub mod_savepoi
{
  my ($type, $file_out, @poi_out) = @_;

  print "Save poi to ($type) $file_out\n";
  print "==================";
  print "=" x length($file_out);
  print "\n";

  # sort array on the latitude
  my @poi_sorted = sort { my %aa = %{$a}; 
                          my %bb = %{$b};
                          $aa{'x'} <=> $bb{'x'} 
                        } @poi_out;

  # Create directory if not exists
  File::Path::mkpath(File::Basename::dirname($file_out));

  # save POIs with specific format
  my $nb_save;
  $nb_save = save_ov2($file_out, @poi_sorted) if ($type =~ /ov2/);
  $nb_save = save_asc($file_out, @poi_sorted) if ($type =~ /asc/);
  
  print "POIs saved : $nb_save\n\n";
}


my $syntax = "syntax: $0 -f file [-w dir] [-h]\n";

my $ver = "merge_ttpoi.pl v1.0 18/03/04\n";

sub usage
{
  print "$ver\n";
  print "Merge several POIs source into one file\n";
  print "\n";
  print "$syntax\n";
  print "Options :\n";
  print " -f : filename of the listing of URLs of POIs to concatenate\n";
  print " -w : directory where to store downloaded files (default : POIs)\n";
  print " -v : show version\n";
  print " -h : this help text\n";
  print "\n";

  exit 0;
}


my $file_lstpoi;
my ($version, $help);


Getopt::Long::GetOptions(
   "f=s" => \$file_lstpoi,
   "w=s" => \$dirpoi,
   "v" => \$version,
   "d" => \$verbose,
   "h" => \$help
   ) or die $syntax;


usage if $help;
die $ver if $version;
die $syntax unless @ARGV == 0;
die $syntax unless defined($file_lstpoi);


my $cat;
my $suspend = 0;

my $nb_line = 0;
open(FILE_POI, $file_lstpoi) or die("Unable to open $file_lstpoi"); 
while(my $line_url=<FILE_POI>)
{
  $nb_line++;
  chomp($line_url);
  $line_url = trim($line_url);
  next if (($line_url =~ /^#/) || ($line_url =~ /^$/));
  
  if (($line_url =~/^\[(.+)\]$/) && ($suspend == 0))
  {
    $cat = $1;
    print "Processing new categorie : [$cat]\n\n";

    # Clear datas
    @lst_poi = ();
    @lst_poi_except = ();
    next;
  }
  
  # suspend module : do not process anything, until resume command
  if ($line_url =~ /^exit$/)
  {
    last;
  }
  
  # suspend module : do not process anything, until resume command
  if ($line_url =~ /^suspend$/)
  {
    $suspend = 1;
    next;
  }

  # resume module : resume processing command
  if ($line_url =~ /^resume$/)
  {
    $suspend = 0;
    next;
  }


  # getpoi module : download and read poi file
  # Format : getpoi format mode url
  #            format : ov2|asc
  if (($line_url =~ /^getpoi +(ov2|asc) +([0-4]) +(.+)$/) && ($suspend == 0))
  {
    my @poi = mod_getpoi($1, $2, $3);

    # add POIs to global list
    push @lst_poi, @poi;

    next;
  }

  # getexcept module : download poi file and use it as exception file
  # Format : getexcept format url
  #            format : ov2|asc
  if (($line_url =~ /^getexcept +(ov2|asc) +(.+)$/) && ($suspend == 0))
  {
    my @poi = mod_getpoi($1, 5, $2);

    # add POIs to global exception list
    push @lst_poi_except, @poi;

    next;
  }

  # getzip module : download and unzip file
  # Format : getzip format url
  if (($line_url =~ /^getzip +(.+)$/) && ($suspend == 0))
  {
    mod_getzip($1);
    next;
  }

  # deldup module : delete duplicate points
  # Format : deldup radius
  #     radius : (integer)(unit)   unit=m(eters) ou y(ards)
  #               ex : 25m ou 12y
  if (($line_url =~ /^deldup +(\d+)([my])$/) && ($suspend == 0))
  {
    my $radius = $1;
    my $unit;
    $unit = "K" if ($2 eq 'm');
    $unit = "M" if ($2 eq 'y');
    @lst_poi = mod_deldup($radius, $unit, @lst_poi);
    next;
  }

  # delexcept module : delete exception points
  # Format : delexcept radius
  #     radius : (integer)(unit)   unit=m(eters) ou y(ards)
  #               ex : 25m ou 12y
  if (($line_url =~ /^delexcept +(\d+)([my])$/) && ($suspend == 0))
  {
    my $radius = $1;
    my $unit;
    $unit = "K" if ($2 eq 'm');
    $unit = "M" if ($2 eq 'y');
    mod_delexcept($radius, $unit);
    next;
  }

  # savestat module : save distance statistics to a file
  #  Args : distance_1 distance_2 ... distance_n [filename]
  #    si filename est omis, les stats sont envoyées sur stdout
  #    ex : distance_n = 10m 20m 40y 100m
  if (($line_url =~ /^savestat +(.+)$/) && ($suspend == 0))
  {
    my @st = split(/ +/, $1);
    my $file_stat = "";
    my @dist_stats;
    for(my $i=0; $i<=$#st; $i++)
    {
      if ($st[$i] =~ /(\d+)([my])/)
      {
         push @dist_stats, $1, $2;
      }
      else
      {
        # last parameter may or may not be the filename. 
        if ($i == $#st)
        {       
          $file_stat = $st[$i];
        }
        else 
        {
          print "Unable to process line $nb_line : $line_url\n";
          print "  Format Error : $st[$i]\n";
          exit(1);      
        } 
      }
    }

    mod_savestat($file_stat, @dist_stats);
    next;
  }

  # saveov2 module : save ov2 file
  if (($line_url =~ /^savepoi +(asc|ov2) +(.+)$/) && ($suspend == 0))
  {
    mod_savepoi($1, $2, @lst_poi);
    next;
  }

  if ($suspend == 0)
  {
    print "Unable to process line $nb_line : $line_url\n";
    exit(1);      
  }
  
}

close(FILE_POI);


#!/usr/bin/perl -w
#
# extract_ttpoi.pl
#
# Laurent Licour
# v1.5 18/09/05
# http://www.licour.com/gps/extract_ttpoi/extract_ttpoi.htm
#
# Ce programme permet d'extraire les POIs des fichiers cartes tomtom 2 & 3 & 5 (fichiers poi.dat)
#
# Attention : compte tenu du copyright existant sur les données utilisées par ce programme,
# ce dernier ne doit pas etre utilisé autrement que pour des fins personnel et experimental.
# Toute reutilsiation et/ou redistribution des données collectées irait a l'encontre du copyright
# des données, et est donc interdite.


use strict;
use Getopt::Long;
use IO;
use File::Basename;


my (%glob_types, %types);
my $verbose = 0;

my ($is_log, $is_ov2, $is_asc, $is_html, $is_carto);


my %poi_us = 
       ( 7367 => "Government Office",
         9364 => "mountain Peak",
         7369 => "Open Parking",
         7313 => "Parking Garage",
         7311 => "Petrol Station",
         7380 => "Railway Station",
         7395 => "Rest Area",
         7383 => "Airport",
         9910 => "Car Dealer",
         7341 => "Casino",
         9906 => "Church",
         7342 => "Cinema",
         7379 => "City Center",
         9352 => "Company",
         9367 => "Concert Hall",
         9363 => "Courthouse",
         7319 => "Cultural Center",
         7385 => "Exhibition Center",
         7352 => "Ferry Terminal",
         7366 => "Frontier Crossing",
         9911 => "Golf Course",
         7321 => "Hospital Polyclinic",
         7314 => "Hotel/Motel",
         7376 => "Tourist Attraction",
         9935 => "mountain Pass",
         7317 => "museum",
         9365 => "Opera",
         7339 => "Place of Worship",
         7324 => "Post Office",
         7312 => "Rent Car Facility",
         9930 => "Rent Car Parking",
         7315 => "Restaurant",
         9361 => "shop",
         7373 => "shopping Center",
         7374 => "stadium",
         7318 => "Theatre",
         7316 => "Tourist Information Office",
         9927 => "Zoo",
         7320 => "sports Centre",
         7322 => "Police Station",
         7365 => "Embassy",
         7377 => "College University",
         7397 => "Cash Dispenser",
         9357 => "Beach",
         9360 => "Ice Skating Ring",
         9369 => "Tennis Court",
         9371 => "Water Sport",
         9373 => "Doctor",
         9374 => "Dentist",
         9375 => "Veterinarian",
         9379 => "Nightlife",
         9902 => "Amusement Park",
         9913 => "Library",
         7310 => "Car Repair Facility",
         7326 => "Pharmacy",
         7337 => "scenic/Panoramic View",
         7338 => "swimming Pool",
         7349 => "Winery",
         7360 => "Camping Ground",
         9362 => "Park and Recreation Area",
         9377 => "Convention Centre",
         9378 => "Leisure Centre",
         9380 => "yacht Basin"
);


my %poi_fr = 
       ( 7367 => "Bureau gouvernemental",
         9364 => "Sommet montagneux",
         7369 => "Parking ouvert",
         7313 => "Parking couvert",
         7311 => "Station-essence",
         7380 => "Gare ferroviaire",
         7395 => "Aire de repos",
         7383 => "Aéroport",
         9910 => "Concessionnaire automobile",
         7341 => "Casino",
         9906 => "Eglise",
         7342 => "Cinéma",
         7379 => "Centre-ville",
         9352 => "Société",
         9367 => "Salle de concerts",
         9363 => "Palais de justice",
         7319 => "Centre culturel",
         7385 => "Centre des expositions",
         7352 => "Terminal de car-ferry",
         7366 => "Frontière",
         9911 => "Terrain de golf",
         7321 => "Hôpital/clinique",
         7314 => "Hôtel/motel",
         7376 => "Site touristique",
         9935 => "Col montagneux",
         7317 => "Musée",
         9365 => "Opéra",
         7339 => "Lieu de recueil",
         7324 => "Bureau de poste",
         7312 => "Centre de location de véhicules",
         9930 => "Parking pour véhicules de location",
         7315 => "Restaurant",
         9361 => "Magasin",
         7373 => "Centre commercial",
         7374 => "Stade",
         7318 => "Théâtre",
         7316 => "Syndicat d'initiative",
         9927 => "Zoo",
         7320 => "Complexe sportif",
         7322 => "Commissariat de police",
         7365 => "Ambassade",
         7377 => "Lycée/université",
         7397 => "Billetterie",
         9357 => "Plage",
         9360 => "Patinoire",
         9369 => "Court de tennis",
         9371 => "Centre de sports aquatiques",
         9373 => "Docteur",
         9374 => "Dentiste",
         9375 => "Vétérinaire",
         9379 => "Activités nocturnes",
         9902 => "Parc d'attractions",
         9913 => "Bibliothèque",
         7310 => "Réparations automobiles",
         7326 => "Pharmacie",
         7337 => "Vue panoramique",
         7338 => "Piscine",
         7349 => "Cave à vins",
         7360 => "Terrain de camping",
         9362 => "Parc et aire de jeux",
         9377 => "Centre de conventions",
         9378 => "Centre de loisirs",
         9380 => "Marina",
         9980 => "Code postal",
         9800 => "Légal/Mandataires",
         9801 => "Légal/Autre"
);



# Decodage des coordonnées GPS des POIs
# Format : 3 octets
sub decode_coord_lon
{
  my ($data, $val1, $val2) = @_;
  
  my ($lon1, $lon2);
  if ($val1 < $val2)
  {
  	$lon1 = $val1;
  	$lon2 = $val2;
  }
  else
  {
  	$lon1 = $val2;
  	$lon2 = $val1;
  }
  
  my $x = unpack("i", $data . "\x00");

  my $max = 0;
  while(! (($x >= $lon1) && ($x <= $lon2)) )
  {
    $x -= 8000000;
    $x += 36000000 if ($x < -18000000);
    $max++;
    die "longitude watchdog ($x $lon1 $lon2)" if ($max >= 4);
  }

  return ($x);
}

sub decode_coord_lat
{
  my ($data, $lat1, $lat2) = @_;
        
  my $x = unpack("i", $data . "\x00");
  return ($x - 8000000);
}


# Record 08 decoding
# The datas are 2bytes-coded, with a table of transposition
sub decode_08
{
  my ($data, $lg_val) = @_;

  # This is the transposition table
  my $code = ". SaerionstldchumgpbkfzvACBMPG-";

  my $desc = "";
  # algorithme d'encodage : 
  # si le bit 7 du prochain octet vaut 0 : les 3 prochains caracteres sont contenus dans 2 octets
  #  (1 bit + 3 * 5 bits) (5 bits/caractere) + 1 bit à 0 en prefixe
  #  les 5 bits correspondent à l'offet dans une chaine de transposition de caracteres
  for (my $i=0; $i<$lg_val; $i+=2)
  {
    # decodage 1er octet
    my $x1 = unpack("c", substr($data, $i, 1));
 
    if (($x1 & 0x80) == 0)
    {
      my $y1 = (($x1 & 0b01111100) >> 2);
      $desc .= substr($code, $y1-1, 1);
 
      # decodage 2eme octet (facultatif en fin de chaine)
      if (($i+1) != $lg_val)
      {
        my $x2 = unpack("c", substr($data, $i+1, 1));
        my $y2 = (($x1 & 0b00000011) << 3) + (($x2 & 0b11100000) >> 5);
        $desc .= substr($code, $y2-1, 1);
        
        my $y3 = ($x2 & 0b00011111);
        if ($y3 != 0)
        {
          $desc .= substr($code, $y3-1, 1);
        }
      }
    }
    else  # bit 0 = 1 : pseudo ASCII sur 7 bits
          # La table suivante est utilisée pour la codage du 1er quartet
          #   1000->0010, 1001->0011, 1010->0100, 1011->0101
          #   1100->0110, 1101->0111, 1110->1110, 1111->1111

    {
    	# Caracteres accentués
    	if (($x1 & 0xE0) == 0xE0)
    	{
    	  $desc .= chr($x1 + 0x100);	# $x1 is signed
    	}
    	# Caracteres normals
    	else
    	{
        $desc .= chr($x1 + 0xA0);  # $x1 is signed
      }
      
      # on ne consomme qu'un octet au lieu de 2 normalement
      $i--;
    }
  }
  
  return ucfirst($desc);
}


# Association table of binary data for type-09 records
my @keys09;
my %btree09 = (
          " " => "0010",
          "a" => "0011",
          "A" => "1010110",
          "b" => "101010",
          "B" => "00001010",
          "c" => "11010",
          "C" => "00000010",
          "d" => "01101",
          "D" => "01100011",
          "e" => "111",
          "E" => "010010101",
          "f" => "0100100",
          "F" => "010001000",
          "g" => "010011",
          "G" => "01000111",
          "h" => "000001",
          "H" => "10100000",
          "i" => "0111",
          "I" => "0000101100",
          "j" => "000010111",
          "J" => "0100010011",
          "k" => "0000000",
          "K" => "000000111",
          "l" => "00011",
          "L" => "10100001",
          "m" => "010000",
          "M" => "00001110",
          "n" => "1001",
          "N" => "0000001100",
          "o" => "1000",
          "O" => "0100011001",
          "p" => "011001",
          "P" => "01000101",
          "q" => "1010111001",
          "Q" => "1010111000000",
          "r" => "0101",
          "R" => "01100000",
          "s" => "00010",
          "S" => "0000100",
          "t" => "1100",
          "T" => "000011111",
          "u" => "11011",
          "U" => "01100001101",
          "v" => "1010011",
          "V" => "000011110",
          "w" => "10100010",
          "W" => "011000010",
          "x" => "1010001100",
          "X" => "01001010010101",
          "y" => "01100010",
          "Y" => "1010111111001",
          "z" => "1010010",
          "Z" => "01000110000",
          "é" => "1010001111",
          "è" => "101000110111",
          "ë" => "10101111110001",
          "ê" => "0000101101110110",
          "ô" => "00001011011110",
          "ö" => "1010001110",
          "ó" => "01100001111",
          "ò" => "10101111110111",
          "õ" => "000010110111010100",
          "î" => "00001011011101111",
          "ï" => "01100001110111011",
          "í" => "10101110100",
          "ì" => "01001010010110",
          "â" => "010001101101001",
          "à" => "0110000111010",
          "ä" => "1010111110",
          "å" => "1010001101011",
          "á" => "010001101100",
          "ã" => "01000110110101",
          "æ" => "010001100010",
          "ç" => "1010111000001",
          "ü" => "0100101000",
          "û" => "101011111100001011",
          "ù" => "010001101101000",
          "ú" => "01001010010111",
          "ÿ" => "000010110111010101011",
          "Â" => "000010110111011101010", 
          "Å" => "01100001110110",
          "Ä" => "1010001101010",
          "À" => "000010110111010110",
          "Á" => "101011111101101",
          "Ã" => "101011111100001001101",
          "Æ" => "1010111111000010100",   
          "Ç" => "011000011101110010001",        
          "É" => "1010111111011000",
          "È" => "0100101001010001",
          "Ê" => "10101111110000100000110",
          "Ë" => "00001011011101110100100",
          "Í" => "01100001110111010",
          "Î" => "00001011011101110100101",
          "Ï" => "101011111100001000010",
          "Ô" => "101011111100001010111",
          "Ö" => "0100011011011",
          "Ò" => "000010110111011101000",
          "Ó" => "00001011011101110110",
          "Û" => "1010111111000001011011",
          "Ü" => "00001011011100",
          "Ú" => "011000011101110001",
          "Ñ" => "10101111110000101010",
          "ñ" => "1010111111010",
          "ß" => "101011110",   
          "ø" => "011000011100",
          "Ø" => "011000011101111", 
          "ª" => "1010111111011001", 
          "ý" => "0100101001010000",   #  U+00FD
					"\x01\x42" => "0000101101110100",   # (l) U+0142
					"\x01\x41" => "101011111100001000110111",  # (L) U+0141
          "0xba" => "0110000111011100101",  # this is a caracter near ° (0xb0)
          "'" => "0100011010",
          "’" => "1010111111000011",
          "`" => "011000011101110011",
          "\$" => "101011111100001001100",
          "\"" => "010001100011",
          "\\" => "011000011101110010000",
          "?" => "101011111100001010110",
          "-" => "01001011",
          "_" => "0000101101110101011",
          ":" => "10101111110000011",
          ";" => "00001011011101010100",
          "." => "0000110",
          "," => "1010111011",
          "&" => "0100010010",
          "#" => "10101111110000100001110",
          "+" => "00001011011111",
          "*" => "101011111100000100",
          "!" => "01100001110111001001",
          ">" => "10101111110000100001101",
          "@" => "0000101101110111011110",
          "°" => "000010110111010101010",
          "/" => "0000001101",
          "0" => "10101110001",
          "1" => "00001011010",
          "2" => "01000110111",
          "3" => "10101110101",
          "4" => "10101111111",
          "5" => "010010100100",
          "6" => "101000110110",  
          "7" => "101000110100",
          "8" => "000010110110",
          "9" => "101011100001",
          "(" => "01001010011",
          ")" => "01100001100",
          "[" => "000010110111010111",
          "]" => "000010110111011100",
          "{" => "101011111100000101000010",
          "}" => "101011111100000101000000",
          "  " => "1010111111000001011010",   # seems to be display as space (shop/iberia : 47 c3 b9 82 44 95 a7 7c d0 eb 07 2d aa 9f 15 d7 af 97 7a)
          "END" => "1011"
          );


# Record 09 decoding
# The datas are coded as a b-tree, each character having a different unique sequence of bits
# (few bits for some characters, many bits for others)
sub decode_09
{
  my ($data) = @_;
          
  # first, transform set of bits as a string of '0' and '1'
  my $res = "";
  for(my $i=0; $i<length($data); $i++)
  {
    my $car = unpack("C", substr($data, $i, 1));
    $res .= reverse sprintf("%08b", $car);
  }

  # scan the hash, to find a correct binary sequence.
  my $len = 0;
  my $code = "";
  while(1)
  {
    my $found = 0;
    
    # search next sequence of bits    
    for(my $i=0; $i<=$#keys09; $i++)
    {
      my $key = $keys09[$i];
      my $val = $btree09{$keys09[$i]};

      # Found a correct sequence
      if (index(substr($res, $len, length($val)) , $val) != -1)
      {
        $len += length($val);
  
        # end of the sequence
        if ($key eq "END")
        {
          $found = 2;
        }
        else
        {
          $code .= $key;
          $found = 1;
        }
        last;
      }
    }
    
    # not found a correct sequence in the b-tree
    if ($found == 0)
    {
      print "Unknow sequence. Unable to complete the analyse : $code (" . substr($res, $len) . ")\n";
      return $code . "???";
    }
  
    # not found the end sequence
    if ($len > length($res))
    {
      print "Decoding error : no ending sequence found : $code (" . substr($res, $len) . ")\n";
      return $code . "???";
    }
  
    # ending sequence  
    last if ($found == 2);
  }
  
  return ucfirst($code);
}


# Record 10 decoding
# The datas are 2bytes-coded with modulo 40, with a table of transposition
sub decode_10
{
  my ($data, $lg_val) = @_;

  # This is the transposition table (39 characters)
  my $code = "abcdefghijklmnopqrstuvwxyz0123456789 .-";

  my $desc = "";
  # algorithme d'encodage : 
  for (my $i=0; $i<$lg_val; $i+=2)
  {
    # decodage de 2 octets si disponible
    if (($i+1) != $lg_val)
    {
      my $x = unpack("S", substr($data, $i, 2));
      for (my $j=0; $j<3; $j++)
      {
      	last if (($x % 40) == 0);
      	$desc .= substr($code, ($x % 40)-1, 1);
      	$x = int($x / 40);
      }
    }
    else
    {
    	# One more character in the string
      my $x = unpack("C", substr($data, $i, 1));
     	last if (($x % 40) == 0);
     	$desc .= substr($code, ($x % 40)-1, 1);
    }
  }

  return ucfirst($desc);
}


# Association table of binary data for type-12 records
# 1st part : description strings 5 bits encoded (all letters except Q)
my %keys12 = (
          "00000" => "a",
          "00001" => "b",
          "00010" => "c",
          "00011" => "d",
          "00100" => "e",
          "00101" => "f",
          "00110" => "g",
          "00111" => "h",
          "01000" => "i",
          "01001" => "j",
          "01010" => "k",
          "01011" => "l",
          "01100" => "m",
          "01101" => "n",
          "01110" => "o",
          "01111" => "p",
          "10000" => "r",		# Caution : no Q letter
          "10001" => "s",
          "10010" => "t",
          "10011" => "u",
          "10100" => "v",
          "10101" => "w",
          "10110" => "x",
          "10111" => "y",
          "11000" => "z",
          "11001" => " ",
          "11010" => ".",		# end of string
          "11011" => "(",
          "11100" => ")",
          "11101" => "&",
          "11110" => "'",
          "11111" => "-"
          );

# 2nd part : Phone number 4 bits encoded
my %keys_tel12 = (
          "0000" => ".",
          "0001" => "0",
          "0010" => "1",
          "0011" => "2",
          "0100" => "3",
          "0101" => "4",
          "0110" => "5",
          "0111" => "6",
          "1000" => "7",
          "1001" => "8",
          "1010" => "9",
          "1011" => "-",
          "1100" => "(",
          "1101" => ")",
          "1110" => "+",
          "1111" => "#"
					);

# Record 12 decoding
sub decode_12
{
  my ($data) = @_;
          
  # first, transform set of bits as a string of '0' and '1'
  my $res = "";
  for(my $i=0; $i<length($data); $i++)
  {
    my $car = unpack("C", substr($data, $i, 1));
    $res .= reverse sprintf("%08b", $car);
  }
  my $max = length($res);
  my $len = 0;
  my $code = "";

  while(1)
  {
  	# Detect prematurly end of sequence
  	if ($len+5 > $max)
  	{
      print "End of sequence. Unable to complete the analyse : $code ($res)\n";
      return $code . "???";
    }

  	my $key = $keys12{reverse(substr($res, $len, 5))};
  	last if ($key eq ".");

  	$code .= $key;
  	$len += 5;		# go to the next 5 bits
  }
 	$len += 5;		# go to the next 5 bits
 	
 	$code .= ">";		# delimit description from phone number
 	
 	# Now Decode Phone Number (4 bits encoding)
  while(1)
  {
  	# Detect prematurly end of sequence (not an error)
  	last if ($len+4 > $max);

  	my $key = $keys_tel12{reverse(substr($res, $len, 4))};
  	last if ($key eq ".");
  	
  	$code .= $key;
  	$len += 4;		# go to the next 4 bits
  }

  return ucfirst($code);
}


sub write_log
{
  my ($level, $str, $data) = @_;

  print FLOG " " x (17-$level);
  print FLOG $str;

   #print FLOG sprintf("  <%0*v2x>", " ", $data) if (($verbose) && ($data));
  print FLOG sprintf("  %d  <%0*v2x>", length($data), "\\x", $data) if (($verbose) && ($data));
  # print FLOG sprintf("  <%0*v8b>", " ", $data);
  print FLOG "\n";
}



sub log_all
{
	my ($level, $x, $y, $d, $data) = @_;
	
	write_log($level, sprintf("(% 9.5f,% 9.5f) %s", $x/100000, $y/100000, $d), $data) if ($is_log);
  write_ov2($x, $y, $d) if ($is_ov2);
  write_asc($x, $y, $d) if ($is_asc);
  write_cartoexplorer_point ($x/100000, $y/100000, $data) if ($is_carto);
}



###################################################################################
# General decoding routine. Record dispatcher
# This is a recursive routine, because of the way records are builds (type 01)
###################################################################################
sub decode
{
  my ($level, $aera_x1, $aera_y1, $aera_x2, $aera_y2) = @_;
  
    
  $level++;
  
  # record type
  my $data;
  my $ret = sysread FH, $data, 1;
  return 0 if ($ret == 0);		# EOF
  
  my $type = sprintf("%0v2d", $data);   # binary to string
  $types{$type}++;
 
  if ($is_log)
  {
    print FLOG " " x $level;
    print FLOG "Record $type  ";
  }

  if ($type eq "01")
  {
    # Record length
    sysread FH, $data, 4;
    my $lg_val = unpack("i", $data);
    my $lg_ori = $lg_val;

    # GPS Position 1
    my ($data1, $data2);
    sysread FH, $data1, 4;
    my $lon1 = unpack("i", $data1);
    sysread FH, $data2, 4;
    my $lat1 = unpack("i", $data2);

    # GPS Position 2
    my ($data3, $data4);
    sysread FH, $data3, 4;
    my $lon2 = unpack("i", $data3);
    sysread FH, $data4, 4;
    my $lat2 = unpack("i", $data4);

    my $dist1 = distance($lon2/100000, $lat2/100000, $lon2/100000, $lat1/100000, "K");
    my $dist2 = distance($lon2/100000, $lat2/100000, $lon1/100000, $lat2/100000, "K");
    
    write_log($level, sprintf("(% 9.5f,% 9.5f) - (% 9.5f,% 9.5f)  %9d km²", $lon2/100000, $lat2/100000, $lon1/100000, $lat1/100000, $dist1*$dist2)) if ($is_log);
    write_cartoexplorer_track ($lon1/100000, $lat1/100000, $lon2/100000, $lat2/100000) if ($is_carto);

    # Record 1 length
    $lg_val -= 21;

    # recursive call
    while($lg_val > 0)
    {
      my $lg = decode($level, $lon1, $lat1, $lon2, $lat2);
      $lg_val -= $lg;
    }

    return $lg_ori;
  }
  #
  # POI from OV2 file
  #
  elsif (($type eq "02") || 
  		   ($type eq "15"))
  {
    # Total length
    sysread FH, $data, 4;
    my $lg_val = unpack("i", $data);
     
    # GPS Position
    sysread FH, $data, 4;
    my $x = unpack("i", $data);
    sysread FH, $data, 4;
    my $y = unpack("i", $data);
    
    # POI Description. Text clear
    sysread FH, $data, $lg_val-13;
    
    log_all($level, $x, $y, $data, $data);

    return ($lg_val);
  }
  #
  # POI with no description
  #
  elsif (($type eq "04") ||
  			 ($type eq "20"))
  {
    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
  
    log_all($level, $x, $y, "", "");
    
    return 7;
  }
  #
  # POI with numerical description (unsigned 2 bytes integer)
  #
  elsif (($type eq "05") ||  # ex : open parking/sweden
         ($type eq "21"))
  {
    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    sysread FH, $data, 2;
    my $d = unpack("S", $data);  # unsigned 2 bytes integer (short)

    log_all($level, $x, $y, $d, $data);
        
    return 9;
  }
  #
  # POI with numerical description (unsigned 3 bytes integer)
  #
  elsif (($type eq "06") ||  # ex : petrol station/italy
         ($type eq "22"))
  {
    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    # POI Description
    sysread FH, $data, 3;
    my $d = unpack("i", $data . "\x00");  # unsigned 3 bytes integer

    log_all($level, $x, $y, $d, $data);
    
    return 10;
  }
  #
  # POI with clear text description
  #
  elsif (($type eq "07") || # ex : PostOffice/Danemark
         ($type eq "23"))
  {
    # Total length
    sysread FH, $data, 1;
    my $lg_val = unpack("c", $data);

    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    # POI Description. Text clear
    sysread FH, $data, $lg_val;
    
    log_all($level, $x, $y, $data, $data);

    return ($lg_val + 8);
  }
  #
  # Record 8 : POI with special encoded description
  #
  elsif (($type eq "08") ||
         ($type eq "24"))      # 0x18
  {
    # Record length
    sysread FH, $data, 1;
    my $lg_val = unpack("c", $data);

    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    # POI Description
    sysread FH, $data, $lg_val;
    my $d = decode_08($data, $lg_val);

    log_all($level, $x, $y, $d, $data);
    
    return $lg_val + 8;
  }
  #
  # Record 9 : POI with special encoded description
  #
  elsif (($type eq "09") ||
         ($type eq "25"))      # 0x19
  {
    # Record length
    sysread FH, $data, 1;
    my $lg_val = unpack("c", $data);

    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    # POI Description
    sysread FH, $data, $lg_val;
    my $d = decode_09($data);
    
    log_all($level, $x, $y, $d, $data);
    
    return $lg_val + 8;
  }
  #
  # Record 10 : POI with special encoded description
  #
  elsif (($type eq "10") ||    # 0x0a
         ($type eq "26"))      # 0x1a  shop/usa-nd...
  {
    # Record length
    sysread FH, $data, 1;
    my $lg_val = unpack("c", $data);

    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);

    # POI description
    sysread FH, $data, $lg_val;
    my $d = decode_10($data, $lg_val);

    log_all($level, $x, $y, $d, $data);
    
    return $lg_val + 8;
  }
  #
  # Record 12 : POI with special encoded description
  #
  elsif (($type eq "12") ||      # 0x0C
         ($type eq "28"))    
  {
    # Record length
    sysread FH, $data, 1;
    my $lg_val = unpack("c", $data);

    # GPS Position
    sysread FH, $data, 3;
    my $x = decode_coord_lon($data, $aera_x1, $aera_x2);
    sysread FH, $data, 3;
    my $y = decode_coord_lat($data, $aera_y1, $aera_y2);
    
    # POI Description
    sysread FH, $data, $lg_val;
    my $d = decode_12($data, $lg_val);

    log_all($level, $x, $y, $d, $data);
    
    return $lg_val + 8;
  }
  else
  {
    print "\nUnknown record type : $type (pos:" . sprintf("0x%x", sysseek(FH, 0, 1) - 1) . ")\n";
    print "Abort !!!\n";
    exit 1; 
  }

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


sub write_csv
{
	
}

sub write_ov2
{
  my ($lon, $lat, $desc) = @_;

  my $data;
  syswrite FOV2, "\x02", 1;
  $data = pack("V", length($desc) + 14);
  syswrite FOV2, $data, 4;
  $data = pack("i", $lon);
  syswrite FOV2, $data, 4;
  $data = pack("i", $lat);
  syswrite FOV2, $data, 4;
  syswrite FOV2, $desc, length($desc);
  syswrite FOV2, "\x00", 1;
}
  
sub write_asc
{
  my ($lon, $lat, $desc) = @_;

#  print FASC sprintf("%10.5f ,%11.5f , \"%s\"", $lon/100000, $lat/100000, $desc) . "\n";
#  $x = sprintf("%15d
  print FASC sprintf("%10.5f ,%11.5f , \"%s\"", $lon/100000, $lat/100000, $desc) . "\n";
}
  


sub init_cartoexplorer_track
{
	print CARTO1 "H  SOFTWARE NAME & VERSION\n";
	print CARTO1 "I  PCX5 2.09\n";
	print CARTO1 "\n";
	print CARTO1 "H  R DATUM                IDX DA             DF             DX             DY             DZ\n";
	print CARTO1 "M  G WGS 84               121 +0.000000e+000 +0.000000e+000 +0.000000e+000 +0.000000e+000 +0.000000e+000\n";
	print CARTO1 "\n";
	print CARTO1 "H  COORDINATE SYSTEM\n";
	print CARTO1 "U  LAT LON DEG\n";
	print CARTO1 "\n";
}


sub write_cartoexplorer_track
{
  my ($lon1, $lat1, $lon2, $lat2) = @_;

	my $strlat1 = (($lat1 < 0)? "S":"N") . sprintf ("%2.7f", abs($lat1));
	my $strlat2 = (($lat2 < 0)? "S":"N") . sprintf ("%2.7f", abs($lat2));

  my $strlon1 =  sprintf ("%.7f", abs($lon1));
	while(index($strlon1, ".") < 3)
	{
		$strlon1 = "0" . $strlon1;
	}
  $strlon1 = (($lon1 < 0)? "W":"E") . $strlon1;

  my $strlon2 =  sprintf ("%.7f", abs($lon2));
	while(index($strlon2, ".") < 3)
	{
		$strlon2 = "0" . $strlon2;
	}
  $strlon2 = (($lon2 < 0)? "W":"E") . $strlon2;

	print CARTO1 "H  LATITUDE    LONGITUDE    DATE      TIME     ALT   ;track\n";
	print CARTO1 "T  $strlat1 $strlon1 01-JAN-05 00:00:00 00000\n";
	print CARTO1 "T  $strlat1 $strlon2 01-JAN-05 00:00:00 00000\n";
	print CARTO1 "T  $strlat2 $strlon2 01-JAN-05 00:00:00 00000\n";
	print CARTO1 "T  $strlat2 $strlon1 01-JAN-05 00:00:00 00000\n";
	print CARTO1 "T  $strlat1 $strlon1 01-JAN-05 00:00:00 00000\n";
	print CARTO1 "\n";
}




my $CartoExplorerPointIdent;

sub init_cartoexplorer_point
{
	print CARTO2 "H  SOFTWARE NAME & VERSION\n";
	print CARTO2 "I  PCX5 2.09\n";
	print CARTO2 "\n";
	print CARTO2 "H  R DATUM                IDX DA             DF             DX             DY             DZ\n";
	print CARTO2 "M  G WGS 84               121 +0.000000e+000 +0.000000e+000 +0.000000e+000 +0.000000e+000 +0.000000e+000\n";
	print CARTO2 "\n";
	print CARTO2 "H  COORDINATE SYSTEM\n";
	print CARTO2 "U  LAT LON DEG\n";
	print CARTO2 "\n";
	print CARTO2 "H  IDNT   LATITUDE    LONGITUDE    DATE      TIME     ALT   DESCRIPTION                              PROXIMITY     SYMBOL ;waypts\n";
	
	$CartoExplorerPointIdent=0;
}

sub write_cartoexplorer_point
{
  my ($lon, $lat, $desc) = @_;
  
  $CartoExplorerPointIdent++;
  
  my $strident = sprintf ("%06d", $CartoExplorerPointIdent);
	my $strlat = (($lat < 0)? "S":"N") . sprintf ("%2.7f", abs($lat));

  my $strlon =  sprintf ("%.7f", abs($lon));
	while(index($strlon, ".") < 3)
	{
		$strlon = "0" . $strlon;
	}
  $strlon = (($lon < 0)? "W":"E") . $strlon;

	print CARTO2 "W  $strident $strlat $strlon 01-JAN-05 00:00:00 00000 $desc          0.00000e+000  00018\n";
  
}
  

my $ver = "extract_ttpoi.pl v1.5 18/09/2005\n";
 
my $syntax = "syntax: $0 -f file -w dir [-a] [-o] [-c] [-l] [-d] [-h] [-v]\n";

sub usage
{
  print "Attention : compte tenu du copyright existant sur les données utilisées par ce programme,\n";
  print "ce dernier ne doit pas etre utilisé autrement que pour des fins personnel et experimental.\n";
  print "Toute reutilsiation et/ou redistribution des données collectées irait a l'encontre du copyright\n";
  print "des données, et est donc interdite.\n";
  print "\n";
  print "$syntax\n";
  print " -f : fichier poi.dat\n";
  print " -w : repertoire ou ecrire les fichiers extraits\n";
  print " -a : ecrire les données sous format ASCII\n";
  print " -o : ecrire les données sous format OV2\n";
  print " -c : ecrire les données sous format CartoExplorer\n";
  print " -l : generate log file\n";
  print " -d : verbose mode\n";
  exit;
}


my ($file_poi, $dir);
my ($version, $help);
my $lang = "fr";  # french


Getopt::Long::GetOptions(
   "f=s" => \$file_poi,
   "w=s" => \$dir,
   "v" => \$version,
   "d" => \$verbose,
   "l" => \$is_log,
   "o" => \$is_ov2,
   "a" => \$is_asc,
   "r" => \$is_html,
   "c" => \$is_carto,
   "h" => \$help,
   "z=s" => \$lang
   ) or die $syntax;


usage if $help;
die $ver if $version;
die $syntax unless @ARGV == 0;
die $syntax unless defined($file_poi);
die $syntax unless defined($dir);
die $syntax unless ($lang =~ /(^fr$)|(^us$)/);


# First, sort Record 09 hash, base on the length of the binary encoding
# for speed optimization
@keys09 = sort { length($btree09{$a}) <=> length($btree09{$b}) } keys %btree09;

# French description (default)
my %poi;
%poi = %poi_fr if ($lang eq "fr");
%poi = %poi_us if ($lang eq "us");



File::Basename::basename($file_poi) =~ /(.*)\.(.*)$/i;
my $basename = $1;
my $ext = $2;

my $nb_cat;
my @cat;


# delete previous files
#unlink <$dir/*.poi>;
#unlink <$dir/*.log>;
#unlink <$dir/*.ov2>;
#unlink <$dir/*.asc>;
unlink <$dir/*>;

	
if ($ext =~ /ov2/i)
{
	die "Can't use -o option with OV2 file" if ($is_ov2);
	
	print "Converting OV2 file\n";
	$nb_cat = 1;
  $cat[0]{'id'}  = 0;     # uniq id of the POI category
 	$cat[0]{'lib'} = "OV2";   # description of the category
 	$cat[0]{'length'} = -s $file_poi;   
 	$cat[0]{'poi_log'} = "$dir/" . $basename . ".log";
 	$cat[0]{'poi_asc'} = "$dir/" . $basename . ".asc";
 	$cat[0]{'poi_ce1'} = "$dir/" . $basename . ".trk";
 	$cat[0]{'poi_ce2'} = "$dir/" . $basename . ".wpt";
 	$cat[0]{'poi'} = "$file_poi";
 	$cat[0]{'offset1'} = 0;
 	$cat[0]{'offset2'} = 0;
}
elsif ($ext =~ /poi/i)
{
	print "Converting POI file\n";
	$nb_cat = 1;
  $cat[0]{'id'}  = 0;     # uniq id of the POI category
 	$cat[0]{'lib'} = "POI";   # description of the category
 	$cat[0]{'length'} = -s $file_poi;   
 	$cat[0]{'poi_log'} = "$dir/" . $basename . ".log";
 	$cat[0]{'poi_asc'} = "$dir/" . $basename . ".asc";
 	$cat[0]{'poi_ov2'} = "$dir/" . $basename . ".ov2";
 	$cat[0]{'poi_ce1'} = "$dir/" . $basename . ".trk";
 	$cat[0]{'poi_ce2'} = "$dir/" . $basename . ".wpt";
 	$cat[0]{'poi'} = "$file_poi";
 	$cat[0]{'offset1'} = 0;
 	$cat[0]{'offset2'} = 0;
}
else
{
	print "Converting POI.DAT file\n";

	open FH, "< $file_poi" or die("Unable to open poi.dat file : $file_poi");
	binmode FH;

	# 1st 4-bytes : nb of categories
	my $data;
	sysread FH, $data, 4;
	$nb_cat = unpack("i", $data);
	print "Nb categories : $nb_cat\n";

	# List categories
	for(my $i=0; $i<$nb_cat; $i++)
	{
	  sysread FH,$data,4;
	  $cat[$i]{'id'}  = unpack("i", $data);     # uniq id of the POI category
  	$cat[$i]{'lib'} = $poi{$cat[$i]{'id'}};   # description of the category
  	if (not defined($cat[$i]{'lib'}))
  	{
	    $cat[$i]{'lib'} = "Undef" . $cat[$i]{'id'};
	  }
	  $cat[$i]{'lib'} =~ s/\//-/;
	}

	# Process each category.
	# Read the offset of the beginig of section in file
	my $offset;
	sysread FH, $offset, 4;
	for(my $i=0; $i<$nb_cat; $i++)
	{
	  $cat[$i]{'offset1'} = unpack("i", $offset);
	  sysread FH, $offset, 4;
	  $cat[$i]{'offset2'} = unpack("i", $offset) - 1;
  	$cat[$i]{'length'} = $cat[$i]{'offset2'} - $cat[$i]{'offset1'} + 1;
	}


	# Read each section, and write it as individual file
	for(my $i=0; $i<$nb_cat; $i++)
	{
	  sysseek FH, $cat[$i]{'offset1'}, 0;
	  sysread FH, $data, $cat[$i]{'length'};
	  $cat[$i]{'poi'} = "$dir/" . $cat[$i]{'lib'} . ".poi";
	
	  if ($cat[$i]{'length'} == 0)
  	{
	    print "Error : bad POI format (no datas for $cat[$i]{'poi'})\n";
  	  exit 1;
  	}	

  	$cat[$i]{'poi_log'} = "$dir/" . $cat[$i]{'lib'} . ".log";
  	$cat[$i]{'poi_ov2'} = "$dir/" . $cat[$i]{'lib'} . ".ov2";
  	$cat[$i]{'poi_asc'} = "$dir/" . $cat[$i]{'lib'} . ".asc";
	 	$cat[$i]{'poi_ce1'} = "$dir/" . $cat[$i]{'lib'} . ".trk";
 		$cat[$i]{'poi_ce2'} = "$dir/" . $cat[$i]{'lib'} . ".wpt";

  	open OUT, ">" .$cat[$i]{'poi'};
  	syswrite OUT, $data, $cat[$i]{'length'};
  	close OUT;
  	my $lgfile = -s $cat[$i]{'poi'};
  	if ($lgfile != $cat[$i]{'length'})
	  {	
    	print "Error : bad POI format (excpected $cat[$i]{'length'} bytes for $cat[$i]{'poi'})\n";
    	exit 1;
  	}
  	if (substr($data, 0, 1) ne "\x01")
  	{
	    print "Error : bad POI format (excpected first byte as \x01 record))\n";
  	  exit 1;
  	}
  	my $lg = unpack("i", substr($data, 1, 4));
  	if ($lgfile != $lg)
  	{
	    print "Error : bad POI format : bad data length (file:$lgfile record:$lg)\n";
  	  exit 1;
  	}
	  
  
	}

	close FH;
}




if ($is_html)
{
  open HTML, ">$dir/extract.html" or die("\nUnable to write html file" );
}

open LST, ">$dir/poi.lst" or die ("\nUnable to write poi.lst file");
 
# And now, process each individual file
for(my $i=0; $i<$nb_cat; $i++)
{
  print "Found : (" . $cat[$i]{'id'} . ") " . $cat[$i]{'lib'};
  STDOUT->flush;

  if ($is_html)
  {
	  print HTML "<TR>\n";
	  print HTML " <TD>" . $cat[$i]{'id'} . "</TD>\n";
	  print HTML " <TD>" . $cat[$i]{'lib'} . "</TD>\n";
  }

  my $poifile = "$dir/" . $cat[$i]{'lib'} . ".poi";
  open FH,"< " . $cat[$i]{'poi'} or die("\nUnable du read '" . $cat[$i]{'poi'} . "'");
  binmode FH;

	print LST "# $cat[$i]{'lib'}\n";
	print LST "$cat[$i]{'id'}=$cat[$i]{'lib'}.poi\n";
	print LST "\n";
  
  if ($is_log)
  {
    open FLOG, "> " . $cat[$i]{'poi_log'} or die("\nUnable to write log file : '" . $cat[$i]{'poi_log'} . "'");

    print FLOG "POI Id           : " . $cat[$i]{'id'} . "\n";
    print FLOG "POI description  : " . $cat[$i]{'lib'} . "\n";
    print FLOG "File offset 1    : " . sprintf("0x%08x", $cat[$i]{'offset1'}) . "\n";
    print FLOG "File offset 2    : " . sprintf("0x%08x", $cat[$i]{'offset2'}) . "\n";
    print FLOG "Length datas     : " . $cat[$i]{'length'} . "\n";
    print FLOG "\n";
  }

  if ($is_ov2)
  {
    open FOV2, "> " . $cat[$i]{'poi_ov2'} or die("\nUnable to write ov2 file : '" . $cat[$i]{'poi_ov2'} . "'");
  }

  if ($is_asc)
  {
    open FASC, "> " . $cat[$i]{'poi_asc'} or die("\nUnable to write asc file : '" . $cat[$i]{'poi_asc'} . "'");

    print FASC "; Readable locations\n";
    print FASC ";\n";
    print FASC "; Longitude,    Latitude, \"Name\"\n";
    print FASC "; ========== ============ ==================================================\n";
    print FASC "\n";
  }

  if ($is_carto)
  {
    open CARTO1, "> " . $cat[$i]{'poi_ce1'} or die("\nUnable to write ce1 file : '" . $cat[$i]{'poi_ce1'} . "'");
    init_cartoexplorer_track;
  }

  if ($is_carto)
  {
    open CARTO2, "> " . $cat[$i]{'poi_ce2'} or die("\nUnable to write ce2 file : '" . $cat[$i]{'poi_ce2'} . "'");
    init_cartoexplorer_point;
  }


  # Start process file  
  my $reste = $cat[$i]{'length'};
  while ($reste != 0)
  {
  	my $val = decode(0, 0, 0, 0, 0);
  	die "Decoding Error" if ($val == 0);
  	$reste -= $val;
  }

  my $nb_total = 0;  
  # Update global statistics
  while (my ($key,$val) = each %types)
  {
    $glob_types{$key} += $val;

    # get real number of POIs
    $nb_total += $val if ($key ne "01");
  }

  if ($is_log)
  { 
    print FLOG "\n";

    # Display statistics
    my @keys = sort keys %types;
    
    for(my $i=0; $i<=$#keys; $i++)
    {
      print FLOG "NbRecord " . $keys[$i]. " : " . $types{$keys[$i]} . "\n";
    }
  }
  
  # Reset statistics
  %types = ();
  
  close FLOG if ($is_log);
  close FOV2 if ($is_ov2);
  close FASC if ($is_asc);
  close CARTO1 if ($is_carto);
  close CARTO2 if ($is_carto);
  close FH;
  
  print "   ($nb_total POIs)\n";

  if ($is_html)
  {
	  print HTML " <TD align='right'>$nb_total</TD>\n";
	  print HTML "</TR>\n";
  }

}

close HTML;
close LST;

print "\n";
print "Global Statistics :\n";
print " Nb categories : $nb_cat\n";

my $total_poi = 0;
my @keys = sort keys %glob_types;
for(my $i=0; $i<=$#keys; $i++)
{
  print " NbRecord " . $keys[$i]. "   : " . $glob_types{$keys[$i]} . "\n";
  
  # Don't add record 01
  if ($keys[$i] ne "01")
  {
  	$total_poi += $glob_types{$keys[$i]};
  }
}
print " Nb POIs : $total_poi\n";

# delete working file if not verbose mode
#unlink <$dir/*.poi> if ($verbose == 0);


#!/usr/bin/env perl
# by Stella Hartono and Aparna Rajpurkar 2014
# This script will convert wig file into a fasta format
# This is useful if you want to call states/peaks using StochHMM
#
# For example, if "A" is anything below 10, "B" is anything above 10, "N" is anything 0:
#
# Wig File:
# variableStep chrom=chr1 span=10
# 1
# 11
# 5.5
# 20
# 0
# 0
#
# Fasta File After:
# >chr1
# ABABNN

use strict; use warnings; 
use Getopt::Std;
use vars qw($opt_i $opt_o);
getopts("i:o:");

# Usage statement
die "usage: $0 -i <input> [Optional: -o <output>]
-i: Input is a single type variableStep wig file.
-o: Output file (optional). Otherwise it will be <input.customfa>.
" unless defined($opt_i);
main();

# DO NOT CHANGE
sub convert {
        my ($number, $value) = @_;
        return("O") if $value <= 1.5;
        if ($value <= 7) {
                return("A") if $number <= -2;
                return("B") if $number <= -0.1;
                return("C") if $number > -0.1 and $number < 0.1;
                return("D") if $number >= 2;
                return("E") if $number >= 0.1;
        }
        else {
                return("V") if $number <= -4;
                return("W") if $number <= -0.1;
                return("X") if $number > -0.1 and $number < 0.1;
                return("Y") if $number >= 4;
                return("Z") if $number >= 0.1;
        }
        die "Died at $number\n";
}



sub main {

  # Input
  my ($input) = ($opt_i);
  die "Input cannot be .customfa!\n" if ($input =~ /.customfa/);

  # FIXME this may be incorrect regex. Use File::Basename if you want to improve it.
  # Or just use -o option
  my ($filename) = getFilename($input);
  my $output = defined($opt_o) ? $opt_o : "$filename.customfa";
	
	# Open input wig file and process
	open (my $in, "<", $input) 	or die "Cannot read from $input: $!\n" if $input !~ /.gz/;
	open ($in, "zcat $input |") 	or die "Cannot read from gunzipped $input: $!\n" if $input =~ /.gz/;
	open (my $out, ">", $output) 	or die "Cannot write to $output: $!\n";
	
	my $chr 	= "INIT";
	my $span 	= 1;
	my $lastpos 	= 0;
	my $lastval	= 0;
	while (my $line = <$in>) {
		chomp($line);
		next if $line =~ /#/;
		next if $line =~ /track/;
	
		# If line is variableStep then extract chromosome
		if ($line =~ /Step/) {
			die "Cannot be used for fixedwig yet!\n" if $line =~ /fixed/;
			print $out "\n" if $chr ne "INIT";
			$lastpos = 0;
			$lastval = 0;

			($chr, $span) = $line =~ /chrom=(.+) span=(\d+)/;
			($chr) = $line =~ /chrom(.+) / if not defined($chr);
			($chr) = $line =~ /chrom(.+)/  if not defined($chr);
			$span = 1 if not defined($span);
			print $out ">$chr\n";
		}
		else {
			die "Died at $line because line is not a wig file number\n" if $line !~ /^\d+/;
				my ($pos, $val) = split("\t", $line);
				if ($lastpos == 0 and $pos != 1) {
					for (my $i = 0; $i < $pos-1; $i++) {
						print $out "O";
					}
					my $number = convert($val, 0);
					print $out "$number";
					$lastval = $val;
				}
				elsif ($pos != $lastpos + $span) {
					my $number = convert(0-$lastval, $lastval);
					print $out "$number";
					for (my $i = $lastpos+1; $i < $pos-1; $i++) {
						print $out "O";
					}
					$number = convert($val - 0, 0);
					print $out "$number";
					$lastval = $val;
				}
				else {
					for (my $i = $pos; $i < $pos+$span; $i++) {
						my $number = convert($val - $lastval, $lastval);
						print $out "$number";
						$lastval = $val;
					}
				}
				$lastpos = $pos;
			}
	}

	close $in;
	close $out;
}


sub getFilename {
   my ($fh, $type) = @_;

   # Split folder and fullname
   my (@splitname) = split("\/", $fh);
   my $fullname = pop(@splitname);
   my @tempfolder = @splitname;
   my $folder = join("\/", @tempfolder);

   # Split fullname and shortname (dot separated)
   @splitname = split(/\./, $fullname);
   my $shortname = $splitname[0];
   return($shortname)          if not defined($type);
   return($folder, $fullname)     if defined($type) and $type =~ /folderfull/;
   return($folder, $shortname)    if defined($type) and $type =~ /folder/;
   return($fullname)        if defined($type) and $type =~ /full/;
   return($folder, $fullname, $shortname)  if defined($type) and $type =~ /all/;
}


#!/usr/bin/perl
# by Stella Hartono 2015
# This script combine bed files, prioritizing HOTSPOT, MEDIUM, HOTSPOT_EXT, then SPARSE for multiple peaks

use strict; use warnings;

my @FILES = @ARGV;
die "Usage: $0 PEAKS1 PEAKS2 PEAKS3 PEAKS4 ETC\n" unless @ARGV;

my ($bedtools_version) = `bedtools --version` =~ /bedtools v(\d+\.\d+)\.?\d*$/;
system("export PATH=\$PATH:./bin/bedtools2_25_0/bin/") and print "- Using bin/bedtools2_25_0/bin/ as bedtools\n" if `which bedtools` !~ /bedtools/ or not defined($bedtools_version) or $bedtools_version < 2.17;

my $count = 0;
my $FILE = "tmp/tempcombine.temp";
my $filename = "output";
while (-e $FILE or -e "$filename.peak") {
	$count ++;
	$FILE = "tmp/tempcombine.temp.$count";
	$filename = "output.$count";
}

system("cat @FILES > $FILE") == 0 or die "Failed to run: cat @FILES > $FILE: $!\n";

process_line($FILE, "HOTSPOT");
process_line($FILE, "MEDIUM");
process_line($FILE, "HOTSPOT_EXT");
process_line($FILE, "SPARSE");

sub process_line {
	my ($FILE, $type) = @_;

	my $type2 = $type eq "HOTSPOT" ? "\^HOTSPOT_[0-9]+" : $type eq "MEDIUM" ? "\^MEDIUM" : $type eq "HOTSPOT_EXT" ? "\^HOTSPOT_EXT" : "\^SPARSE";
	my $output = "tmp/$filename.$type.TEMP";
	mkdir "tmp" if not -d "tmp";
	my @subtract;
	push(@subtract, "bedtools subtract -a - -b tmp/$filename.HOTSPOT.TEMP") if ($type ne "HOTSPOT");
	push(@subtract, "bedtools subtract -a - -b tmp/$filename.MEDIUM.TEMP") if ($type ne "HOTSPOT" and $type ne "MEDIUM");
	push(@subtract, "bedtools subtract -a - -b tmp/$filename.HOTSPOT_EXT.TEMP") if ($type ne "HOTSPOT" and $type ne "MEDIUM" and $type ne "HOTSPOT_EXT");
	open (my $out, ">", $output) or die "Cannot write to $output: $!\n";

	my $cmd = "awk '\$4 ~ /$type2/ {print}' $FILE |sort -k1,1 -k2,2n | bedtools merge -i -";
	for (my $i = 0 ; $i < @subtract; $i++) {
		$cmd .= " | $subtract[$i]";
	}
#	print "\n$FILE $type:\t$cmd\n";

	my @line = `$cmd`;

	for (my $i = 0; $i < @line; $i++) {
		my $line = $line[$i];
		chomp($line);
		my ($chr, $beg, $end) = split("\t", $line);
		my $name = "$type\_$i";
		my $strand = $FILE =~ /_neg/ ? "-" : "+";
		print $out "$chr\t$beg\t$end\t$name\t0\t$strand\n";
	}
}

system("cat tmp/$filename.*.TEMP |sort -k1,1 -k2,2n > $filename.PEAK && /bin/rm tmp/$filename.* $FILE");
my ($linecount) = `wc -l $filename.PEAK` =~ /^[ ]*(\d+)/;
print "\e[1;35mFinal Combine Step \e[0;32mSUCCESS!\e[0m: $0 @FILES\n";
print "\n\e[1;31mOutput = $filename.PEAK\e[0m (\e[0;32m$linecount\e[0m peaks)\n\n";

print STDERR "\n\e[1;32mSUCCESS!\e[0m\n\n";

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

#!/usr/bin/perl

use strict; use warnings;

my ($bedtools_version) = `bedtools --version` =~ /bedtools v(\d+\.?\d*)\.?\d*/;

print "\n";
print "- bedtools version > 2.17 found!\e[0;32m " . `which bedtools` . "\e[0m" if `which bedtools` =~ /bedtools/ and defined($bedtools_version) and $bedtools_version >= 2.17;
print "- stochhmm found!\e[0m\e[0;32m " . `which stochhmm` . "\e[0m" if `which stochhm` !~ /stochhmm/;

system("export PATH=\$PATH:./bin/bedtools2_25_0/bin/") and print "- Using bin/bedtools2_25_0/bin/ as bedtools\n" if `which bedtools` !~ /bedtools/ or not defined($bedtools_version) or $bedtools_version < 2.17;
system("export PATH=\$PATH:./bin/StochHMM/") and print "- Using bin/StochHMM/ as stochhmm\n" if `which stochhm` !~ /stochhmm/;
print "\n";

my ($FILE_LOCATION) = @ARGV;
die "Usage: $0 file.txt\n\n" unless @ARGV;

my @FILES = `awk '\$1 ~ /\\w+/ {print}' $FILE_LOCATION`;
my @FILENAMES;
my $totalfile = @FILES;

for (my $i = 0; $i < @FILES; $i++) {
	my $FILEorig = $FILES[$i];
	chomp($FILEorig);
	my ($filename) = getFilename($FILEorig);
	push(@FILENAMES, "$filename.peak");
	mkdir "tmp" if not -d "tmp";
	my $filenum = $i + 1;
	print "\e[33mProcessing File $FILEorig ($filenum/$totalfile)\e[0m\n";
	my $cmd1 = "./bin/1_wig2fa.pl -i $FILEorig -o tmp/$filename.1"; 
	system($cmd1) == 0 or die "Failed to run bin/1_wig2fa.pl -i $FILEorig -o tmp/$filename.1: $!\n";
	print "\e[1;35m- Step 1/5 \e[0;32mSUCCESS!\e[0m: $cmd1\n";
	my $cmd2 = "stochhmm -seq tmp/$filename.1 -model model/DRIPc_1.hmm -posterior -threshold 0.95 -gff | awk '\$2 == \"StochHMM\" {print \$1\"\\t\"\$4\"\\t\"\$5\"\\t\"\$3\"\\t0\\t+\"}' > tmp/$filename.2"; 
	system($cmd2) == 0 or die "Failed to run stochhmm of tmp/$filename.1: $!\n";
	print "\e[1;35m- Step 2/5 \e[0;32mSUCCESS!\e[0m: $cmd2\n";
	my $cmd3 = "./bin/2_bed2fa.pl -i tmp/$filename.2 -o tmp/$filename.3"; 
	system($cmd3) == 0 or die "Failed to run bin/2_bed2fa.pl -i tmp/$filename.2 -o tmp/$filename.3: $!\n";
	print "\e[1;35m- Step 3/5 \e[0;32mSUCCESS!\e[0m: $cmd3\n";
	my $cmd4 = "stochhmm -seq tmp/$filename.3  -model model/DRIPc_2.hmm -posterior -threshold 0.95 -gff | awk '\$2 == \"StochHMM\" {print \$1\"\\t\"\$4\"\\t\"\$5\"\\t\"\$3\"\\t0\\t+\"}' > tmp/$filename.4"; 
	system($cmd4) == 0 or die "Failed to run stochhmm of tmp/$filename.3: $!\n";
	print "\e[1;35m- Step 4/5 \e[0;32mSUCCESS!\e[0m: $cmd4\n";
	my $cmd5 = "./bin/3_Combine.pl tmp/$filename.4"; 
	system($cmd5) == 0 or die "Failed to run bin/3_Combine.pl: $!\n";
	print "\e[1;35m- Step 5/5 \e[0;32mSUCCESS!\e[0m: $cmd5\n";
	my ($linecount) = `wc -l $filename.peak` =~ /^[ ]*(\d+)/;
	print "\e[0;33m$FILEorig done! Output = $filename.peak\e[0m (\e[0;32m$linecount\e[0m peaks)\n";
	print "\n";
}

my $cmd6 = "./bin/4_CombineAll.pl @FILENAMES";
system($cmd6) == 0 or die "Failed to run bin/4_CombineAll.pl @FILENAMES: $!\n";
#print "\e[1;35mFinal Combine Step \e[0;32mSUCCESS!\e[0m: $cmd6\n";

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


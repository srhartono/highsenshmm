#!/usr/bin/perl

use strict; use warnings;

my ($FILE) = @ARGV;
die "Usage: $0 filename.bedfa.2\n\n" unless @ARGV;


my ($bedtools_version) = `bedtools --version` =~ /bedtools v(\d+\.\d+)\.?\d*$/;
system("export PATH=\$PATH:./bin/bedtools2_25_0/bin/") and print "- Using bin/bedtools2_25_0/bin/ as bedtools\n" if `which bedtools` !~ /bedtools/ or not defined($bedtools_version) or $bedtools_version < 2.17;
my ($filename) = getFilename($FILE);

process_line($FILE, "HOTSPOT");
process_line($FILE, "MEDIUM");
process_line($FILE, "HOTSPOT_EXT");
process_line($FILE, "SPARSE");

sub process_line {
	my ($FILE, $type) = @_;

	my $type2 = $type eq "HOTSPOT" ? "\^HIGH\$" : $type eq "MEDIUM" ? "\^MEDIUM\$" : $type eq "HOTSPOT_EXT" ? "^SPARSE_HIGH" : "\^SPARSE\$";
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

system("cat tmp/$filename.*.TEMP > $filename.peak");

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








__END__
cat $FILE | awk '$4 == "MEDIUM" {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tMEDIUM\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP > MEDIUM.temp && name.pl MEDIUM.temp MEDIUM.TEMP && /bin/rm MEDIUM.temp

cat $FILE | awk '$4 ~ /SPARSE_HIGH/ {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tHOTSPOT_EXT\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP | bedtools subtract -a - -b MEDIUM.TEMP > HOTSPOT_EXT.temp && 
name.pl HOTSPOT_EXT.temp HOTSPOT_EXT.TEMP && /bin/rm HOTSPOT_EXT.temp


cat $FILE | awk '$4 == "SPARSE" {print}' |sort -k1,1 -k2,2n | bedtools merge -i - |perl -pi -e 's/$/\tSPARSE\t0\t+/' | 
bedtools subtract -a - -b HOTSPOT.TEMP |bedtools subtract -a - -b MEDIUM.TEMP |
bedtools subtract -a - -b HOTSPOT_EXT.TEMP > SPARSE.temp &&
name.pl SPARSE.temp SPARSE.TEMP && /bin/rm SPARSE.temp

cat *.TEMP |sort -k1 -k2,2n > Peaks.final
/bin/rm *.TEMP


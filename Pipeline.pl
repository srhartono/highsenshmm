#!/usr/bin/perl

use strict; use warnings;

my ($FILE) = @ARGV;
die "Usage: $0 wigfile.wig\n" unless @ARGV;

my $stochhmm = `which stochhmm`;
$stochhmm = "bin/StochHMM/stochhmm" if $stochhmm !~ /stochhmm/;

system("./bin/1_wig2fa.pl -i $FILE.wig -o $FILE.customfa") == 0 or die "Failed to run ./bin/1_wig2fa.pl -i $FILE.wig -o $FILE.customfa: $!\n";
system("$stochhmm -seq $FILE.customfa -model ./model/DRIPc_1.hmm -posterior -threshold 0.95 -gff | awk '\$2 == \"StochHMM\" {print \$1\"\\t\"\$4\"\\t\"\$5\"\\t\"\$3\"\\t0\\t+\"}' > $FILE.1") == 0 or die "Failed to run $stochhmm of $FILE.customfa: $!\n";
system("./bin/2_bed2fa.pl -i $FILE.1 -o $FILE.1.bedfa") == 0 or die "Failed to run ./bin/2_bed2fa.pl -i $FILE.1 -o $FILE.1.bedfa: $!\n";
system("stochhmm -seq $FILE.1.bedfa  -model DRIPc_2.hmm -posterior -threshold 0.95 -gff | awk '\$2 == \"StochHMM\" {print \$1\"\\t\"\$4\"\\t\"\$5\"\\t\"\$3\"\\t0\\t+\"}' > $FILE.2") == 0 or die "Failed to run $stochhmm of $FILE.1.bedfa: $!\n";

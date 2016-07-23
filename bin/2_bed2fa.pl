#!/usr/bin/perl
# by Stella Hartono 2015
# Similar to wig2fa, this script convert bed file to fasta

use strict; use warnings; use mitochy; use Getopt::Std;
getopts("i:o:");
use vars qw($opt_i $opt_o);

my ($input1) = $opt_i;
die "usage: $0 -i <bed file from DRIPc_1.hmm stochhmm (MUST BE SORTED)> [optional: -o output]\n" unless defined($input1);

my ($folder1, $fileName1) = mitochy::getFilename($input1, "folder");
my $output = defined($opt_o) ? $opt_o : "$fileName1.bedfa";

my $lastpos = 1;
my $lastchr = "INIT";
my $count = 0;
my $temp = 0; #to check error
open (my $in1, "<", $input1) or die "Cannot read from $input1: $!\n";
open (my $out, ">", "$output") or die "Cannot write to $output: $!\n";
while (my $line = <$in1>) {
	chomp($line);
	next if $line =~ /^#/;
	next if $line =~ /^track/;
	next if $line =~ /\tBREAK\t/;
	my ($chr, $start, $end, $type, $zero, $strand) = split("\t", $line);
	if ($lastchr ne $chr) {
		print $out "\n" if $lastchr ne "INIT";
		print $out ">$chr\n";
		$lastchr = $chr;
		$lastpos = 1;
		$temp = 0;
	}
	if ($lastpos > $start) {
		print "WARNING!!! (lastpos = $lastpos, start = $start)\n" if $lastpos != $start + 1;
		$start = $lastpos;
	}
	if ($lastpos ne $start) {
		for (my $i = $lastpos; $i < $start; $i++) {
			$temp ++;
			print $out "N";
			$count ++;
		}
	}
	for (my $i = $start; $i < $end+1; $i++) {
		if ($type =~ /LOW/i) {
			print $out "L";
			$temp ++;
		}
		else {
			print $out "H";
			$temp ++;
		}
		$count ++;
	}
	die "ERROR!lastpos $lastpos Died at $line\n" if $temp != $end and $temp != $end - 1;
	$lastpos = $end+1;
}
close $in1;
close $out;

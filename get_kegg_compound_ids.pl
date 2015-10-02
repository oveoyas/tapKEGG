#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

# Name output file and open it.
my $outfilename = "kegg_compound_ids";
open OUT, '>', $outfilename or die "Could not open $outfilename";

# Get list of KEGG compounds (using KEGG API).
my $content = get('http://rest.kegg.jp/list/compound') or die 'Unable to get list of compounds from KEGG';
# Split content into lines.
my @lines = split "\n", $content;

# Loop through lines. Get compound IDs and print them to output file.
my $line_number = 1;
my $id_cnt = 0;
my $unrec_cnt = 0;
foreach my $line (@lines) {
	if ($line =~ m/^cpd:(C\d{5})\s/) {
		print OUT "$1\n";
		$id_cnt++;
	} else {
		my @tmp = split " ", $line;
		print "Unrecognized compound ID on line $line_number: $tmp[0]\n";
		$unrec_cnt++;
	}
	$line_number++;
}
close OUT;

print "Wrote $id_cnt KEGG compound IDs to the file $outfilename.\n";
print "$unrec_cnt compounds had unrecognizable IDs.\n" if $unrec_cnt > 0;

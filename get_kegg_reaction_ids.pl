#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

# Name output file and open it.
my $outfilename = "kegg_reaction_ids";
open OUT, '>', $outfilename or die "Could not open $outfilename";

# Get list of KEGG reactions (using KEGG API).
my $content = get('http://rest.kegg.jp/list/reaction') or die 'Unable to get list of reactions from KEGG';
# Split content into lines.
my @lines = split "\n", $content;

# Loop through lines. Get reaction IDs and print them to output file.
my $line_number = 1;
my $id_cnt = 0;
my $unrec_cnt = 0;
foreach my $line (@lines) {
	if ($line =~ m/^rn:(R\d{5})\s/) {
		print OUT "$1\n";
		$id_cnt++;
	} else {
		my @tmp = split " ", $line;
		print "Unrecognized reaction ID on line $line_number: $tmp[0]\n";
		$unrec_cnt++;
	}
	$line_number++;
}
close OUT;

print "Wrote $id_cnt KEGG reaction IDs to the file $outfilename.\n";
print "$unrec_cnt reactions had unrecognizable IDs.\n" if $unrec_cnt > 0;

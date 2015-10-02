#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

# Initialize filename variables. Get name of input file from command line or user input.
my $infilename;
if ($#ARGV < 0) {
	print "Argument was not provided, please enter name of input file: ";
	$infilename = <STDIN>;
	chomp $infilename;
} else {
	$infilename = shift @ARGV;
}
my $outfilename = "kegg_compound_entries";

# Open input file;
open IN, '<', $infilename or die "Could not open $infilename";

my @ids = ();

while (defined(my $line = <IN>)) {
	chomp $line;
	push @ids, $line;
}
close IN;

# Can only fetch ten entries at a time.
my $offset = 10;

# Open output file.
open OUT, '>', $outfilename or die "Could not open $outfilename";

# Get KEGG entries for all compound IDs.
for (my $i = 0; $i < scalar @ids; $i += 10) {	
	$offset = $#ids - $i if $#ids - $i < 10;
	my $str = join "+", @ids[$i .. $i + $offset];
	my $content = get("http://rest.kegg.jp/get/$str") or die "Unable to get list of compounds from KEGG";
	print OUT $content;
	print "$i out of ", scalar @ids, " compound IDs processed...\n" if $i % 500 == 0 and $i != 0;
}
close OUT;
print "Wrote ", scalar @ids, " KEGG compound entries to the file $outfilename.\n";

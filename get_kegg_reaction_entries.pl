#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

# Declare and initialize filename variables. Get name of input file from command line or user input.
my $infilename;
if ($#ARGV < 0) {
	print "Argument was not provided, please enter name of file containing KEGG reaction IDs: ";
	$infilename = <STDIN>;
	chomp $infilename;
} else {
	$infilename = shift @ARGV;
}
my $outfilename = "kegg_reaction_entries";

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

# Get KEGG entries for all reaction IDs.
for (my $i = 0; $i < scalar @ids; $i += 10) {	
	$offset = $#ids - $i if $#ids - $i < 10;
	my $str = join "+", @ids[$i .. $i + $offset];
	my $content = get("http://rest.kegg.jp/get/$str") or die "Unable to get list of reactions from KEGG";
	print OUT $content;
	print "$i out of ", scalar @ids, " reaction IDs processed...\n" if $i % 500 == 0 and $i != 0;
}
close OUT;
print "Wrote ", scalar @ids, " KEGG reaction entries to the file $outfilename.\n";

__END__

# This is nicer, but perhaps slower because of the splicing (?)

# Get KEGG entries for all reaction IDs.
while (scalar @ids > 0) {
	$offset = scalar @ids if scalar @ids < 10;
	my @tmp = splice @ids, 0, $offset;
	my $str = join "+", @tmp;
	print "$str\n";
	my $content = get("http://rest.kegg.jp/get/$str") or die 'Unable to get list of reactions from KEGG';
	print OUT $content;
}

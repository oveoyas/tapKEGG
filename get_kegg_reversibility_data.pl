#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

# Name output file
my $outfilename = "kegg_reversibility_data";

print "Getting list of KEGG pathway IDs...\n";

# Get list of KEGG pathways
my $content = get("http://rest.kegg.jp/list/pathway/rn") or die "Unable to get list of pathways from KEGG";
# Store lines in array
my @pathway_lines = split "\n", $content;

# Get pathway IDs and store them in array
my @pathway_ids = ();
my $i = 0;
my $unrec_cnt = 0;
foreach my $line (@pathway_lines) {
	if ($line =~ m/^path:(rn\d{5})\s/) {
		$pathway_ids[$i] = $1;
	} else {
		print "Unrecognized pathway ID on line ", $i + 1, "\n";
		$unrec_cnt++;
	}
	$i++;
}

print "Getting KEGG pathway entries and extracting reaction data...\n";

# Get reactions for each pathway ID. Store information in hash of hashes.
my %data = ();
my $pathway_cnt = 0;
foreach my $pathway_id (@pathway_ids) {
	# Get KGML entry for pathway
	my $entry = get("http://rest.kegg.jp/get/$pathway_id/kgml") or die "Unable to get list of compounds from KEGG";
	# Store lines in array
	my @kgml_lines = split "\n", $entry;
	my $reaction_flag = 0;
	my @reaction_ids = ();
	my $reversibility = "";
	my @substrates = ();
	my @products = ();
	foreach my $line (@kgml_lines) {
		if ($line =~ m/^(\s+)?\<reaction\s+/) {
			@reaction_ids = $line =~ m/rn:(R\d{5})/g;
			$reversibility = $1 if $line =~ m/\s+type="(\w+)"\>/;
			$reaction_flag = 1;
		}
		if ($reaction_flag == 1) {
			if ($line =~ m/^(\s+)?\<\/reaction\>/) {
				foreach my $reaction_id (@reaction_ids) {
					my $left_side = join " + ", @substrates;
					my $right_side = join " + ", @products;
					my $arrow = "";
					$arrow = "=>" if $reversibility eq "irreversible";
					$arrow = "<=>" if $reversibility eq "reversible";
					$data{$reaction_id}{$pathway_id} = "$left_side $arrow $right_side";
				}
				$reaction_flag = 0;
				@reaction_ids = ();
				$reversibility = "";
				@substrates = ();
				@products = ();
			} else {
				push @substrates, $1 if $line =~ m/\<substrate\s+id="\d+"\s+name="cpd:(C\d{5})"\/\>/;
				push @products, $1 if $line =~ m/\<product\s+id="\d+"\s+name="cpd:(C\d{5})"\/\>/;
			}
		}
	}
	$pathway_cnt++;
	print "$pathway_cnt out of ", scalar @pathway_ids, " pathway entries processed...\n" if $pathway_cnt % 10 == 0 and $pathway_cnt != 0;
}

# Open output file
open OUT, '>', $outfilename or die "Could not open $outfilename";

print "Writing reversibility data to file...\n";
my $line_cnt = 0;
# Print to file
foreach my $reaction_id (sort keys %data) {
	foreach my $pathway_id (sort keys %{$data{$reaction_id}}) {
		print OUT "$reaction_id\t$pathway_id\t$data{$reaction_id}{$pathway_id}\n";
		$line_cnt++;
	}
}

close OUT;

print "Job finished. Wrote $line_cnt lines of reversibility data to file $outfilename.\n";

# tapKEGG

tapKEGG consists of a few Perl scripts that get compound and reaction data from KEGG databases and save it as text files.

Requires the [LWP::Simple](http://search.cpan.org/dist/libwww-perl/lib/LWP/Simple.pm) module and an Internet connection (obviously).

## Usage

The scripts `get_kegg_compound_ids.pl` and `get_kegg_reaction_ids.pl` get lists of all compound and reaction identifiers, respectively. The scripts `get_kegg_compound_entries.pl` and `get_kegg_reaction_entries.pl` get the full entries of compounds and reactions and require lists of identifiers as input. For example, if you want to get all reaction entries, do something like this in a UNIX environment:
```
./get_kegg_reaction_ids
./get_kegg_reaction_entries kegg_reaction_ids
```
Getting identifiers is typically fast (seconds) and getting entries is typically slower (minutes, maybe hours). This is primarily because the KEGG API only allows ten entries to be retrieved at a time.

`get_kegg_reversibility_data.pl` extracts all reaction directionalities from all reactions that are part of pathways in the KEGG PATHWAY database (a reaction may have different directionalities in different pathways). Running time should only be a few minutes. This script actually gets the data by parsing XML files - I would be interested to know if there is a more practical way to do this.

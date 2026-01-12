# sialic_acid_catalog

This repository describes the steps and corresponding scripts used for the construction of a multi-level curated database of sialic acid metabolic proteins, as well as the scripts used for data visualization throughout the pipeline.

## Local database establishment:

This section covers the retrieval of protein sequences from public databases and additional processing steps to condense the data and make it easier to handle.

1) Sequence download: sequence_downloads (folder) 
2) Removal of redundancy within individual databases: CDHIT_within_databases.sh
3) Header recoding: header_recoding (folder)
4) Merging of database files using the Unix cat command: databases_merge.sh 
6) Removal of redundancy across databases: CDHIT_across_databases.sh
7) UpSet plot representation of sequence intersections across databases: upsetplot.ipynb

## Homology-based filtering and similarity analysis: 

This section describes the sequence-based analyses performed in the pipeline.
The first three steps involve the alignment of sequences from the local database against reference sequences and the analysis of the resulting alignments.
The last two steps involve cross-alignments of reference sequences for the same protein across different organisms.

1) Alignment between the local database and reference sequences: alignments (folder)
2) Graphical visualization of the proportion of aligned and unaligned sequences: unaligned_seqs.ipynb
3) Graphical visualization of alignment-derived parameters
4) Cross-alignments among reference sequences
5) Heatmap visualization of cross-alignment results among reference sequences

## Functional analysis with InterProScan:

This section describes the functional analysis of sequences in the local database based on conserved signatures from multiple resources integrated into InterProScan.
First, InterProScan is executed locally via its command-line interface for both local database sequences and reference sequences.
Second, sequences lacking the essential signature are removed from the local database.
Finally, sequences containing signatures not observed in any of the reference sequences also removed.

1) Local execution of InterProScan
2) Essential signature filtering
3) Exclusion of sequences with inadequate signatures

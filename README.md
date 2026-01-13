# sialic_acid_catalog

This repository describes the steps and corresponding scripts used for the construction of a multi-level curated database of sialic acid metabolic proteins, as well as the scripts used for data visualization throughout the pipeline.

## 1. Local database establishment:

This section covers the retrieval of protein sequences from public databases and additional processing steps to condense the data and make it easier to handle.

1.1. Sequence download: sequence_downloads (folder) 

1.2. Removal of redundancy within individual databases: CDHIT_within_databases.sh

1.3. Header recoding: header_recoding (folder)

1.4. Merging of database files using the Unix cat command: databases_merge.sh 

1.5. Removal of redundancy across databases: CDHIT_across_databases.sh

1.6. UpSet plot representation of sequence intersections across databases: upsetplot.ipynb

## 2. Homology-based filtering and similarity analysis: 

This section describes the sequence-based analyses performed in the pipeline.
The first three steps involve the alignment of sequences from the local database against reference sequences and the analysis of the resulting alignments.
The last two steps involve cross-alignments of reference sequences for the same protein across different organisms.

2.1. Alignment between the local database and reference sequences: alignments (folder)

2.2. Graphical visualization of the proportion of aligned and unaligned sequences: unaligned_seqs.ipynb

2.3. Graphical visualization of alignment-derived parameters: alignment_parameters (folder)

2.4. Cross-alignments among reference sequences: reference_cross_alignments.sh

2.5. Heatmap visualization of cross-alignment results among reference sequences: cross_alignment_heatmap.ipynb

## 3. Functional analysis with InterProScan:

This section describes the functional analysis of sequences in the local database based on conserved signatures from multiple resources integrated into InterProScan.
First, InterProScan is executed locally via its command-line interface for both local database sequences and reference sequences.
Second, sequences lacking the essential signature are removed from the local database.
Finally, sequences containing signatures not observed in any of the reference sequences also removed.

3.1. Local execution of InterProScan: interproscan.sh

3.2. Essential signature filtering and exclusion of sequences with inadequate signatures: signatures_comparison.ipynb

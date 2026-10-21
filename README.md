# Sialic acid catalog

This repository describes the steps and corresponding scripts used for the construction of a multi-level curated database of sialic acid metabolic proteins, as well as the scripts used for data visualization throughout the pipeline.

## Pipeline Walkthrough

<img width="1831" height="1670" alt="pipeline walkthrough drawio(1)" src="https://github.com/user-attachments/assets/6e96966d-9184-4570-960f-3e737153de8c" />


### 1. Local database establishment:

This section covers the retrieval of protein sequences from public databases and additional processing steps to condense the data and make it easier to handle.

1.1. Sequence download: sequence_downloads (folder) 

1.2. Removal of redundancy within individual databases: CDHIT_within_databases.sh

1.3. Assign internal IDs from original headers and recode original FASTA: header_recoding (folder)

1.4. Merging of database files using the Unix cat command: databases_merge.sh 

1.5. Removal of redundancy across databases: CDHIT_across_databases.sh

1.6. UpSet plot representation of sequence intersections across databases: upsetplot.ipynb

### 2. Homology-based filtering and similarity analysis: 

This section describes the sequence-based analyses performed in the pipeline.
The first three steps involve the alignment of sequences from the local database against reference sequences and the analysis of the resulting alignments.
The last two steps involve cross-alignments of reference sequences for the same protein across different organisms.

2.1. Alignment between the local database and reference sequences: alignments (folder)

2.2. Graphical visualization of the proportion of aligned and unaligned sequences: unaligned_seqs.ipynb

2.3. Graphical visualization of alignment-derived parameters: alignment_parameters (folder)

2.4. Cross-alignments among reference sequences: reference_cross_alignments.sh

2.5. Heatmap visualization of cross-alignment results among reference sequences: cross_alignment_heatmap.ipynb

### 3. Functional analysis with InterProScan:

This section describes the functional analysis of sequences in the local database based on conserved signatures from multiple resources integrated into InterProScan.
First, InterProScan is executed locally via its command-line interface for both local database sequences and reference sequences.
Second, sequences lacking the essential signature are removed from the local database.
Finally, sequences containing signatures not observed in any of the reference sequences also removed.

3.1. Local execution of InterProScan: interproscan.sh

3.2. Essential signature filtering and exclusion of sequences with inadequate signatures: signatures_comparison.ipynb

## Benchmark Walkthrough

<img width="1086" height="817" alt="image" src="https://github.com/user-attachments/assets/8587e6b7-3b8e-45c7-9bee-8865473ed644" />

## Benchmark Walkthrough

This part of the repository describes how the annotation performance of the six SialoCat databases (DB1–DB6) was evaluated on genomic and metagenomic data, as well as the scripts used for each step.

<img width="1086" height="817" alt="benchmark walkthrough" src="https://github.com/user-attachments/assets/8587e6b7-3b8e-45c7-9bee-8865473ed644" />

### 1. Preparing SialoCat for annotation performance evaluation:

This section describes the conversion of the SialoCat databases (FASTA format) into the formats required by the two annotation strategies evaluated: sequence alignment with DIAMOND and predicted structural similarity with TM-Vec.
All six databases are converted into DIAMOND databases.
For TM-Vec, only DB6 is used. It is first clustered at 60% identity with CD-HIT (DB6_nr60), and the representative sequences are then used to build a TM-Vec search database for each protein.

1.1. Conversion of DB1–DB6 into DIAMOND databases (DIAMOND makedb): alignments/makedb.sh

1.2. Clustering of DB6 at 60% identity with CD-HIT: tmvec (folder)

1.3. Construction of the TM-Vec search database from DB6_nr60: tmvec (folder)

## 2. Genomic annotation performance evaluation:

This section describes the functional annotation of 22 control bacterial proteomes with experimentally characterized sialic acid metabolism (Supplementary Table 2 of the manuscript).
Protein FASTA files for each genome were downloaded from the NCBI Genome database and are available in the control_proteomes folder.

Two annotation strategies were compared:
First, the control proteomes are searched against the DB6 TM-Vec database, and hits are retained at two predicted TM-score thresholds (≥ 0.9 and ≥ 0.7).
Second, the control proteomes are aligned against each of the six SialoCat DIAMOND databases (DIAMOND v2.1.10, top HSP only), and hits are retained when they satisfy all of the following: identity ≥ 40%, e-value ≤ 1e-4, bitscore ≥ 50, query coverage ≥ 0.4 and subject coverage ≥ 0.4.

2.1. Functional annotation of the control proteomes with the DB6 TM-Vec database, followed by score filtering: tmvec (folder)

2.2. Functional annotation of the control proteomes by alignment against DB1–DB6 with DIAMOND, followed by hit filtering: control_proteome_annotation (folder)

## 3. Metagenomic annotation performance evaluation:

This section describes the functional annotation of fecal metagenomes from control individuals and patients with inflammatory bowel disease (ulcerative colitis and Crohn's disease) (SRA BioProject PRJNA1198911; Orejudo et al., 2025).
Before annotation, reads were quality-filtered with fastp v0.23.2, human reads were removed by alignment against GRCh38.p14 with bowtie2 v2.5.4 and samtools v1.22.1, and paired-end reads were merged.

Three annotation strategies were compared:
First, reads are aligned with DIAMOND BLASTX v2.0.15 against the six SialoCat databases.
Second, reads are aligned with DIAMOND BLASTX v2.0.15 against UniRef90 (humann4_protein_database_filtered_v2019_06.dmnd, downloaded with HUMAnN v4.0.0.alpha.1), and hits are annotated with KO terms using the HUMAnN utility mapping database.
Third, reads are annotated with the full HUMAnN v4.0.0.alpha.1 pipeline, and the output is regrouped to KO terms.

The same filtering thresholds were applied to the DIAMOND alignments against SialoCat and UniRef90, matching those of HUMAnN's translated search step (identity > 50%, e-value < 1, query coverage > 0.9), except for subject coverage. A more permissive subject coverage threshold (> 0.1) was used, because a single read cannot reach the subject coverage that HUMAnN achieves by pooling reads before computing this metric.

3.1. Functional annotation of the metagenomes by alignment against DB1–DB6: metagenomes_diamond_annotation (folder)

3.2. Functional annotation of the metagenomes by alignment against UniRef90 and KO mapping: metagenomes_diamond_annotation (folder)

3.3. Functional annotation of the metagenomes with HUMAnN and regrouping to KO: metagenome_humann_annotation (folder)

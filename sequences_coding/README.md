## This folder contains the scripts used to generate dataframes with internal codes assign from original database headers for all sequences from the BV-BRC database and to rename the FASTA files based on these codes. 

## Workflow:

Run code_generation_bv.py to assign internal IDs to the sequences, extracted from the original database headers.

Run sequences_coding_bv.py to rename the FASTA files using the internal IDs generated in the previous step.

## Example files:

cpsK_bv.fasta — example input for code_generation_bvbrc.py.

cpsK_bv_codes_df.csv — example output from code_generation_bvbrc.py.

cpsK_bv_coded.fasta — example final output from sequences_coding_bvbrc.py.

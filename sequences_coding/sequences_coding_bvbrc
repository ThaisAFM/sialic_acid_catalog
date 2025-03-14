# This script takes as input a dataframe that correlates the original identifiers of each sequence 
# with new codes in the 'gene_X_database' format and outputs a new FASTA file with the original 
# headers replaced by the new codes.

# Due to the large number of sequences to be coded, this stage was carried out in a Linux terminal.

# You will need a directory named according to your database with all the fasta files, 
# an empty directory named database_coded and a directory named database_code_dataframes 
# containing the csv file with the codes for all sequences (result of the script described in
# 'code_generation_bvbrc.ipynb'). 

#!/usr/bin/env python3

import os
import pandas as pd
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

input_dir = 'bvbrc'
output_dir = 'bvbrc_coded'

df = pd.read_csv('bvbrc_code_dataframes/bvbrc_merged_df.csv')

# List all FASTA files in the input directory
fasta_files = [f for f in os.listdir(input_dir) if f.endswith('.fasta')]

# Loop to process each FASTA file
for fasta_file in fasta_files:
    # Full path to the input file
    input_path = os.path.join(input_dir, fasta_file)

    # Read the sequences from the FASTA file
    records = list(SeqIO.parse(input_path, 'fasta'))

    # List to store the updated sequences
    new_records = []

    # Replace headers
    for record in records:
        if record.id in df['Header'].values:
            # Get the corresponding new code
            new_code = df.loc[df['Header'] == record.id, 'Gene_Code'].values[0]

            # Create a new sequence with the updated header
            new_record = SeqRecord(record.seq, id=new_code, description='')
            new_records.append(new_record)
        else:
            # Keep the original sequence if the header is not in the DataFrame
            new_records.append(record)

    # Output file name (adds the _coded suffix)
    output_file = fasta_file.replace('.fasta', '_coded.fasta')
    output_path = os.path.join(output_dir, output_file)

    # Save the updated sequences to the output file
    SeqIO.write(new_records, output_path, 'fasta')

    print(f"File processed: {fasta_file} -> {output_file}")

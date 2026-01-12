import os
import pandas as pd
from Bio import SeqIO

def sequence_coding(fasta_file, input_filename, output_dir):
    """
    Process a FASTA file to generate a DataFrame containing headers and internal gene codes,
    saving the result in a specified output directory.

    Args:
        fasta_file (str): Path to the input FASTA file.
        input_filename (str): Name of the input file (used for generating codes).
        output_dir (str): Directory where the output CSV will be saved.

    Returns:
        None
    """

    # List to store the headers
    headers = [record.id for record in SeqIO.parse(fasta_file, "fasta")]

    # Create a DataFrame with the headers
    df = pd.DataFrame(headers, columns=['Header'])

    # Add a column with gene codes in the format gene_X_bv
    df['Gene_Code'] = [
        f"{input_filename.split('_')[0]}_{i + 1}_{input_filename.split('_')[1].replace('.fasta', '')}"
        for i in range(len(headers))
    ]

    # Save the DataFrame to the output directory
    output_filename = os.path.join(output_dir, f"{input_filename.split('.')[0]}_codes_df.csv")
    df.to_csv(output_filename, index=False)


# Directory where the input FASTA files are located
directory = 'bvbrc'  # adapt as needed

# Create output directory name
output_directory = f"{directory}_code_dataframes"
os.makedirs(output_directory, exist_ok=True)  # create if it doesn't exist

# List all files in the directory and filter for FASTA files
fasta_files = [f for f in os.listdir(directory) if f.endswith('.fasta')]

# Process each FASTA file
for fasta_file in fasta_files:
    full_path = os.path.join(directory, fasta_file)
    sequence_coding(full_path, fasta_file, output_directory)

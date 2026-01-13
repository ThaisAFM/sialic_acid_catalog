import pandas as pd
import glob
import os

# Directory where the .outfmt6 files are located
directory = "./"

# Create output directory
output = "./csvs"
os.makedirs(output, exist_ok=True)

# File pattern (adjust according to the real extension: .out, .outfmt6, etc.)
files = glob.glob(os.path.join(directory, "*.outfmt6"))

# DIAMOND columns
columns = ["qseqid", "sseqid", "pident", "ppos", "length",
           "evalue", "bitscore", "qlen", "slen"]

for file in files:
    df = pd.read_csv(file, sep="\t", names=columns)
    df = df.astype({
        "pident": float,
        "ppos": float,
        "length": int,
        "evalue": float,
        "bitscore": float,
        "qlen": int,
        "slen": int
    })

    # Avoid division by zero
    df = df[df["qlen"] > 0]

    df["length_ratio"] = (df["slen"] / df["qlen"]) * 100
    df["coverage"] = df["length"] * 100 / df["slen"]

    # Base name of the output file
    base_name = os.path.basename(file).replace(".outfmt6", ".csv")
    output_path = os.path.join(output, base_name)

    # Save DataFrame as CSV
    df.to_csv(output_path, index=False)

    print(f"File processed and saved to: {output_path}")

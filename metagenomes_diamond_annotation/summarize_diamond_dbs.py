"""
Summarize DIAMOND best hits against the sialic acid databases (DB1-DB6).

For each database, reads every DIAMOND_<DB>/<DB>_best_hit/<sample>_besthit.tsv
(output of diamond_reads_filter.ipynb) and counts READS per function
(one line of a best-hit file = one read).

  - function: taken from the sseqid, up to the first "_" (e.g. nanA_... -> nanA)
  - sample name: file name without "_besthit.tsv"
  - function list: mean_gene_lengths.csv (column "Function"); every
    sample x function combination is reported, with 0 when there are no reads

Output: DBs_HITS_summary/<DB>_HITS_summary_scov.tsv
(columns Function, Sample, counts)

Usage:
    python summarize_diamond_dbs.py
"""

import glob
import os
from pathlib import Path

import pandas as pd

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
DBS = ["DB1", "DB2", "DB3", "DB4", "DB5", "DB6"]
MEAN_LENGTHS_CSV = Path("mean_gene_lengths.csv")
OUTPUT_DIR = Path("DBs_HITS_summary")


def summarize_db(db, functions):
    diamond_dir = Path(f"DIAMOND_{db}") / f"{db}_best_hit"

    dfs = []
    for file in glob.glob(os.path.join(diamond_dir, "*_besthit.tsv")):
        sample = os.path.basename(file).replace("_besthit.tsv", "")

        df = pd.read_csv(
            file,
            sep="\t",
            header=0,              # file already has a header
            usecols=["sseqid"],    # only column used
            engine="pyarrow",      # faster parser (remove if pyarrow is not installed)
        )

        # reads per function
        counts = (
            df["sseqid"].str.split("_").str[0]
            .value_counts()
            .rename_axis("Function")
            .reset_index(name="counts")
        )
        counts["Sample"] = sample
        dfs.append(counts)

    if not dfs:
        print(f"[WARNING] {db}: no *_besthit.tsv files in {diamond_dir}, skipping")
        return

    summary = pd.concat(dfs, ignore_index=True)

    # all Sample x Function combinations (missing ones = 0)
    samples = summary["Sample"].unique()
    idx = pd.MultiIndex.from_product([samples, functions], names=["Sample", "Function"])

    summary = (
        summary
        .set_index(["Sample", "Function"])
        .reindex(idx, fill_value=0)
        .reset_index()
    )[["Function", "Sample", "counts"]]

    out_path = OUTPUT_DIR / f"{db}_HITS_summary_scov.tsv"
    summary.to_csv(out_path, sep="\t", index=False)
    print(f"{db}: {len(samples)} samples -> {out_path}")


def main():
    functions = pd.read_csv(MEAN_LENGTHS_CSV)["Function"].unique()
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for db in DBS:
        summarize_db(db, functions)


if __name__ == "__main__":
    main()

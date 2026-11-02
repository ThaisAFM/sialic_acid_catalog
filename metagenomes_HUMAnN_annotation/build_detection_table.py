"""
Build the table of detected sialic acid–related functions per sample, for
every annotation method.

Methods:
  KO      - HUMAnN gene families regrouped by KEGG Orthology, relab-normalized
            (humann_genefamilies_ko_relab.tsv)
  EC      - HUMAnN gene families regrouped by EC number, relab-normalized
            (humann_genefamilies_ec_relab.tsv)
  DB1-DB6 - DIAMOND against the sialic acid databases
  UNIREF  - DIAMOND against UniRef90, grouped by KO
            (DBs_HITS_summary/<METHOD>_HITS_summary_scov.tsv)

Detected = number of features of interest present in the sample:
  - KO:            KOs of interest with relab > 0
  - EC:            ECs of interest with relab > 0
  - DIAMOND-based: functions with counts > 0
Every sample of a method is reported, with Detected = 0 when nothing is found.

The "_merged" suffix is removed from sample names so that samples match
across methods.

Output: plot_df_all_methods.tsv (columns Sample, Method, Detected)
"""

import glob
import os
from pathlib import Path

import pandas as pd

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
KO_TABLE = Path("humann_genefamilies_ko_relab.tsv")
EC_TABLE = Path("humann_genefamilies_ec_relab.tsv")
DB_DIR = Path("DBs_HITS_summary")      # folder with the *_HITS_summary_scov.tsv files
OUTPUT = Path("plot_df_all_methods.tsv")

# KEGG Orthologs of interest
KOS_OF_INTEREST = [
    "K00983",  # NeuA
    "K12247",  # Lic3X
    "K00785",  # lst
    "K12246",  # NeuD
    "K22247",  # NeuO
    "K09689",  # KpsT
    "K22923",  # KpsT
    "K01654",  # NeuB
    "K24257",  # NeuC
    "K08068",  # NeuC
    "K01639",  # NanA
    "K00885",  # NanK
    "K01788",  # NanE
    "K01443",  # NagA
    "K02564",  # NagB
    "K22104",  # NanR
    "K22110",  # NanC
    "K03290",  # NanT
    "K17948",  # NanM
    "K09475",  # OmpC
    "K09476",  # OmpF
    "K11688",  # SiaP
    "K11689",  # SiaQ
    "K11690",  # SiaT
    "K05970",  # SIAE
    "K01186",  # NanH
]

# EC numbers of interest
ECS_OF_INTEREST = [
    "2.7.7.43",   # NeuA
    "2.4.3.4",    # Lic3A
    "2.4.3.8",    # Lic3B
    "2.4.3.6",    # lst
    "2.3.1.136",  # NeuO
    "7.6.2.12",   # KpsT
    "2.5.1.56",   # NeuB
    "3.2.1.183",  # NeuC
    "4.1.3.3",    # NanA
    "2.7.1.60",   # NanK
    "5.1.3.9",    # NanE
    "3.5.1.25",   # NagA
    "3.5.99.6",   # NagB
    "5.1.3.24",   # NanM
    "3.1.1.53",   # SIAE
    "3.2.1.18",   # NanH
]


def detected_from_humann(table, features, method):
    """Number of features of interest with relab > 0, per sample."""
    df = pd.read_csv(table, sep="\t")
    df = df.rename(columns={df.columns[0]: "Feature"})

    # keep only unstratified rows and the features of interest
    df = df[~df["Feature"].str.contains("|", regex=False)]
    df = df[df["Feature"].isin(features)]

    samples = [c for c in df.columns if c != "Feature"]
    detected = (df[samples] > 0).sum(axis=0)   # features absent from the table count as 0

    return pd.DataFrame({
        "Sample": samples,
        "Method": method,
        "Detected": detected.values,
    })


def detected_from_diamond(file):
    """Number of functions with counts > 0, per sample."""
    method = Path(file).stem.replace("_HITS_summary_scov", "")   # e.g. DB1
    df = pd.read_csv(file, sep="\t")

    detected = (
        (df["counts"] > 0)
        .groupby(df["Sample"])
        .sum()
        .reset_index(name="Detected")
    )
    detected["Method"] = method
    return detected[["Sample", "Method", "Detected"]]


def main():
    tables = [
        detected_from_humann(KO_TABLE, KOS_OF_INTEREST, "KO"),
        detected_from_humann(EC_TABLE, ECS_OF_INTEREST, "EC"),
    ]

    for file in sorted(glob.glob(os.path.join(DB_DIR, "*_HITS_summary_scov.tsv"))):
        tables.append(detected_from_diamond(file))

    plot_df = pd.concat(tables, ignore_index=True)
    plot_df["Sample"] = plot_df["Sample"].str.replace("_merged", "", regex=False)
    plot_df["Detected"] = plot_df["Detected"].astype(int)

    plot_df.to_csv(OUTPUT, sep="\t", index=False)

    print(plot_df.groupby("Method")["Sample"].nunique().rename("n_samples").to_string())
    print(f"\nSaved: {OUTPUT}")


if __name__ == "__main__":
    main()

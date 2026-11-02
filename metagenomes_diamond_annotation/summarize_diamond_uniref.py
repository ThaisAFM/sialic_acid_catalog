"""
Summarize DIAMOND best hits against UniRef90 (HUMAnN database), using the same
logic as the DB1-DB6 summaries (summarize_diamond_dbs.py):

  - input: DIAMOND_UNIREF/UNIREF_best_hit (output of diamond_reads_filter.ipynb;
    filters: evalue < 1, pident > 50, qcovhsp > 90, scovhsp > 10)
  - counts READS (one line of a best-hit file = one read), not distinct IDs
  - sample name: file name without "_besthit.tsv"
  - host_disease: taken from the sample metadata table

The only unavoidable difference from the DBs: UniRef90 sseqids carry no gene
name, so the function comes from the HUMAnN KO -> UniRef90 utility mapping,
through the FUNCTIONS dictionary below. Reads whose best hit is a UniRef90
cluster with no KO of interest are not assigned to any function.

Outputs:
  DBs_HITS_summary/UNIREF_HITS_summary_scov.tsv
      columns Function, Sample, counts, host_disease
  DBs_HITS_summary/UNIREF_HITS_summary_scov_diagnostics.tsv
      columns Sample, total_reads, reads_assigned

Usage:
    python summarize_diamond_uniref.py
"""

import csv
import glob
import gzip
import os
import sys
from itertools import combinations
from pathlib import Path

# ------------------------------------------------------------------------------
# Configuration (edit the paths to match your system)
# ------------------------------------------------------------------------------
BESTHIT_DIR = Path("DIAMOND_UNIREF") / "UNIREF_best_hit"
MAPPING = Path("/path/to/humann_databases/utility_mapping/map_ko_uniref90.txt.gz")
METADATA = Path("samples_with_metadata.csv")   # columns "Sample" and "host_disease"
OUTPUT = Path("DBs_HITS_summary") / "UNIREF_HITS_summary_scov.tsv"
DIAG_OUTPUT = Path("DBs_HITS_summary") / "UNIREF_HITS_summary_scov_diagnostics.tsv"

# Function -> KOs (one or more KOs per function)
FUNCTIONS = {
    "neuA": ["K00983"],
    "lic3X": ["K12247"],
    "lst": ["K00785"],
    "neuD": ["K12246"],
    "neuO": ["K22247"],
    "kpsT": ["K09689", "K22923"],
    "neuB": ["K01654"],
    "neuC": ["K24257", "K08068"],
    "nanA": ["K01639"],
    "nanK": ["K00885"],
    "nanE": ["K01788"],
    "nagA": ["K01443"],
    "nagB": ["K02564"],
    "nanR": ["K22104"],
    "nanC": ["K22110"],
    "nanT": ["K03290"],
    "nanM": ["K17948"],
    "ompC": ["K09475"],
    "ompF": ["K09476"],
    "siaP": ["K11688"],
    "siaQ": ["K11689"],
    "siaT": ["K11690"],
    "SIAE": ["K05970"],
    "nanH": ["K01186"],
}


def load_uniref_to_function():
    """Read the mapping once and return {UniRef90_ID: function}."""
    kos_of_interest = {ko for kos in FUNCTIONS.values() for ko in kos}
    ko_to_unirefs = {}
    with gzip.open(MAPPING, "rt") as f:
        for line in f:
            cols = line.rstrip("\n").split("\t")
            if cols[0] in kos_of_interest:
                ko_to_unirefs[cols[0]] = set(cols[1:])
                if len(ko_to_unirefs) == len(kos_of_interest):
                    break

    missing = sorted(kos_of_interest - ko_to_unirefs.keys())
    if missing:
        print(f"[WARNING] KOs with no UniRef90 in the mapping (function may be 0): {missing}")

    func_to_unirefs = {
        func: set().union(*(ko_to_unirefs.get(ko, set()) for ko in kos))
        for func, kos in FUNCTIONS.items()
    }

    # A UniRef90 shared by two functions would count the same read twice.
    for a, b in combinations(FUNCTIONS, 2):
        shared = func_to_unirefs[a] & func_to_unirefs[b]
        if shared:
            sys.exit(f"ERROR: {len(shared)} UniRef90 IDs shared between {a} and {b}.")

    return {u: func for func, unirefs in func_to_unirefs.items() for u in unirefs}


def load_host_disease():
    sample_to_disease = {}
    with open(METADATA, newline="") as f:
        for row in csv.DictReader(f):
            sample_to_disease[row["Sample"]] = row["host_disease"]
    return sample_to_disease


def count_sample(path, uniref_to_function):
    """Count reads per function in a *_besthit.tsv file (with header)."""
    counts = dict.fromkeys(FUNCTIONS, 0)
    n_reads = 0
    with open(path) as f:
        header = next(f).rstrip("\n").split("\t")
        sseqid_col = header.index("sseqid")
        for line in f:
            n_reads += 1
            # sseqid looks like "UniRef90_XXXX|<length>"
            sseqid = line.split("\t", sseqid_col + 1)[sseqid_col].split("|")[0]
            func = uniref_to_function.get(sseqid)
            if func is not None:
                counts[func] += 1
    return counts, n_reads


def main():
    files = sorted(glob.glob(str(BESTHIT_DIR / "*_besthit.tsv")))
    if not files:
        sys.exit(f"ERROR: no *_besthit.tsv files in {BESTHIT_DIR}")

    uniref_to_function = load_uniref_to_function()
    sample_to_disease = load_host_disease()

    rows, diag = [], []
    for i, path in enumerate(files, 1):
        sample = os.path.basename(path).replace("_besthit.tsv", "")
        counts, n_reads = count_sample(path, uniref_to_function)

        disease = sample_to_disease.get(sample)
        if disease is None:
            print(f"[WARNING] {sample} has no host_disease in {METADATA.name}")
            disease = "NA"

        for func in FUNCTIONS:
            rows.append({"Function": func, "Sample": sample,
                         "counts": counts[func], "host_disease": disease})

        assigned = sum(counts.values())
        diag.append({"Sample": sample, "total_reads": n_reads,
                     "reads_assigned": assigned})
        print(f"[{i}/{len(files)}] {sample}: {n_reads} reads, {assigned} assigned")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)

    # Write to a temporary file and replace at the end (no half-written output)
    tmp = OUTPUT.with_suffix(".tmp")
    with open(tmp, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["Function", "Sample", "counts", "host_disease"],
                                delimiter="\t")
        writer.writeheader()
        writer.writerows(rows)
    os.replace(tmp, OUTPUT)

    with open(DIAG_OUTPUT, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["Sample", "total_reads", "reads_assigned"],
                                delimiter="\t")
        writer.writeheader()
        writer.writerows(diag)

    print(f"\nSaved: {OUTPUT} ({len(rows)} rows = {len(files)} samples x {len(FUNCTIONS)} functions)")
    print(f"Diagnostics: {DIAG_OUTPUT}")


if __name__ == "__main__":
    main()

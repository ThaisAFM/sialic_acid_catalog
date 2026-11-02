#!/bin/bash
# ==============================================================================
# TM-Vec batch search pipeline
# ------------------------------------------------------------------------------
# Runs a TM-Vec structural similarity search for every combination of:
#     query proteome (./proteomes/*.faa)  x  TM-Vec database (./tmvec_database_all/*/)
#
# Reference (single search with the official CLI):
#     https://github.com/flatironinstitute/deepblast/wiki/Searching-proteins
#
#     tmvec-search --query <proteome.faa> \
#                  --database <db.npy> --metadata <meta.npy> \
#                  --output <out.tsv> \
#                  --tm-vec-model tm_vec_cath_model_large.ckpt \
#                  --tm-vec-config 49181518_tm_vec_cath_model_large_params.json
#
# Calling `tmvec-search` once per combination reloads the ProtTrans and TM-Vec
# models every time, which is very slow. This pipeline instead:
#
#   STEP 1 - Builds a job list (tmvec_jobs.tsv) with one line per pending
#            proteome x database combination. Combinations whose output file
#            already exists and is non-empty are skipped, so the pipeline can be
#            safely resumed.
#
#   STEP 2 - Runs a single Python process that loads ProtTrans and TM-Vec only
#            once and iterates over the job list. It also caches:
#              - the embeddings of each proteome (reused across databases)
#              - the index of each database (reused across proteomes)
#            The output format is the same as `tmvec-search`: one row per
#            query/hit with columns query_id, rank, database_id, tm-score.
#
# Usage:
#     bash run_tmvec_pipeline.sh
# ==============================================================================
 
set -uo pipefail
 
# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------
PROTEOMES_DIR="./proteomes"
DATABASES_DIR="./tmvec_database_all"
OUTPUT_DIR="tmvec_DB6_outputs"
TM_VEC_MODEL="tm_vec_cath_model_large.ckpt"
TM_VEC_CONFIG="49181518_tm_vec_cath_model_large_params.json"
PROTRANS_MODEL="Rostlab/prot_t5_xl_uniref50"
DEVICE="cpu"          # "cpu" or "gpu"
K=5                   # number of nearest hits reported per query protein
JOB_LIST="tmvec_jobs.tsv"
 
mkdir -p "$OUTPUT_DIR"
: > "$JOB_LIST"
 
# ==============================================================================
# STEP 1 - Build the job list
# ------------------------------------------------------------------------------
# Each database folder must contain two .npy files:
#   - the embedding database (any .npy whose name does not contain "meta")
#   - the metadata file      (a .npy whose name contains "meta")
# Output columns (tab-separated, no header):
#   db_file  meta_file  proteome  out_file
# ==============================================================================
for db_dir in "$DATABASES_DIR"/*/; do
    db_name=$(basename "$db_dir")
 
    db_file=$(find "$db_dir" -maxdepth 1 -iname "*.npy" ! -iname "*meta*" | head -n 1)
    meta_file=$(find "$db_dir" -maxdepth 1 -iname "*meta*.npy" | head -n 1)
 
    if [[ -z "$db_file" || -z "$meta_file" ]]; then
        echo "[WARNING] Skipping $db_name - db/meta .npy files not found" >&2
        continue
    fi
 
    for proteome in "$PROTEOMES_DIR"/*.faa; do
        proteome_name=$(basename "$proteome" .faa)
        out_file="$OUTPUT_DIR/${db_name}_${proteome_name}.tsv"
 
        # already done? skip
        [[ -s "$out_file" ]] && continue
 
        printf "%s\t%s\t%s\t%s\n" "$db_file" "$meta_file" "$proteome" "$out_file" >> "$JOB_LIST"
    done
done
 
N_TOTAL=$(wc -l < "$JOB_LIST")
echo "Pending jobs: $N_TOTAL"
 
if [[ "$N_TOTAL" -eq 0 ]]; then
    echo "Nothing to do."
    exit 0
fi
 
# ==============================================================================
# STEP 2 - Run all searches in a single Python process
# ------------------------------------------------------------------------------
# Models are loaded once; proteome embeddings and database indexes are cached
# in memory and reused across jobs.
# Note: this step uses internal functions from the tm_vec package
# (encode, load_database, query) instead of the `tmvec-search` CLI.
# ==============================================================================
python3 - \
    --job-list "$JOB_LIST" \
    --tm-vec-model "$TM_VEC_MODEL" \
    --tm-vec-config "$TM_VEC_CONFIG" \
    --protrans-model "$PROTRANS_MODEL" \
    --device "$DEVICE" \
    --k "$K" <<'PYTHON'
import argparse
import gc
from pathlib import Path
 
import numpy as np
import pandas as pd
import torch
from Bio import SeqIO
from transformers import T5EncoderModel, T5Tokenizer
 
from tm_vec.embed_structure_model import trans_basic_block, trans_basic_block_Config
from tm_vec.tm_vec_utils import encode, load_database, query
 
# ------------------------------------------------------------------------------
# Arguments
# ------------------------------------------------------------------------------
parser = argparse.ArgumentParser()
parser.add_argument("--job-list", type=Path, required=True)
parser.add_argument("--tm-vec-model", type=Path, required=True)
parser.add_argument("--tm-vec-config", type=Path, required=True)
parser.add_argument("--protrans-model", type=str, default="Rostlab/prot_t5_xl_uniref50")
parser.add_argument("--device", type=str, default="cpu")
parser.add_argument("--k", type=int, default=5)
args = parser.parse_args()
 
device = (torch.device("cuda:0")
          if (args.device == "gpu" and torch.cuda.is_available())
          else torch.device("cpu"))
print(f"Using device: {device}", flush=True)
 
# ------------------------------------------------------------------------------
# Load models (once)
# ------------------------------------------------------------------------------
print("Loading ProtTrans...", flush=True)
tokenizer = T5Tokenizer.from_pretrained(args.protrans_model, do_lower_case=False)
model = T5EncoderModel.from_pretrained(args.protrans_model)
model = model.to(device).eval()
gc.collect()
 
print("Loading TM-Vec model...", flush=True)
tm_vec_model_config = trans_basic_block_Config.from_json(str(args.tm_vec_config))
model_deep = trans_basic_block.load_from_checkpoint(
    str(args.tm_vec_model), config=tm_vec_model_config, map_location=device)
model_deep = model_deep.to(device).eval()
 
# ------------------------------------------------------------------------------
# Job list
# ------------------------------------------------------------------------------
jobs = pd.read_csv(args.job_list, sep="\t", header=None,
                   names=["db_file", "meta_file", "proteome", "out_file"])
 
# ------------------------------------------------------------------------------
# Caches
# ------------------------------------------------------------------------------
embedding_cache = {}
 
def get_embeddings(proteome_path):
    """Embed a proteome once and reuse it for every database."""
    if proteome_path not in embedding_cache:
        headers, seqs = [], []
        with open(proteome_path) as handle:
            for record in SeqIO.parse(handle, "fasta"):
                headers.append(record.id)
                seqs.append(str(record.seq))
        queries = encode(seqs, model_deep, model, tokenizer, device)
        embedding_cache[proteome_path] = (headers, queries)
    return embedding_cache[proteome_path]
 
index_cache = {}
 
def get_index(db_file):
    """Load a database index once and reuse it for every proteome."""
    if db_file not in index_cache:
        index_cache[db_file] = load_database(db_file)
    return index_cache[db_file]
 
# ------------------------------------------------------------------------------
# Run searches
# ------------------------------------------------------------------------------
n_ok, n_skip, n_err = 0, 0, 0
 
for row in jobs.itertuples(index=False):
    db_file, meta_file, proteome, out_file = row
    out_path = Path(out_file)
 
    if out_path.exists() and out_path.stat().st_size > 0:
        n_skip += 1
        continue
 
    try:
        headers, queries = get_embeddings(proteome)
        index = get_index(db_file)
        metadata_database = np.load(meta_file)
 
        D, I = query(index, queries, args.k)
 
        near_ids = np.array([list(metadata_database[I[i]]) for i in range(I.shape[0])])
 
        nids = pd.DataFrame(near_ids, index=headers)
        nids.index.name = "query_id"
        nids = pd.melt(nids.reset_index(), id_vars="query_id",
                       var_name="rank", value_name="database_id")
        tms = pd.DataFrame(D, index=headers)
        tms = pd.melt(tms, var_name="query_id", value_name="tm-score")
        nids = pd.concat((nids, tms[["tm-score"]]), axis=1)
        nids = nids.sort_values(["query_id", "rank"])
 
        out_path.parent.mkdir(parents=True, exist_ok=True)
        nids.to_csv(out_path, sep="\t", index=None)
 
        print(f"[OK]    {out_path.name}", flush=True)
        n_ok += 1
    except Exception as e:
        print(f"[ERROR] {out_path.name}: {e}", flush=True)
        n_err += 1
 
print(f"\nDone. OK={n_ok} SKIP={n_skip} ERROR={n_err}")
PYTHON

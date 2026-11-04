#!/bin/bash
set -uo pipefail

PROTEOMES_DIR="./proteomes"
DATABASES_DIR="./tmvec_database_all"
OUTPUT_DIR="tmvec_DB6_outputs"
JOB_LIST="tmvec_jobs.tsv"

: > "$JOB_LIST"

for db_dir in "$DATABASES_DIR"/*/; do
    db_name=$(basename "$db_dir")

    db_file="${db_dir}db.npy"
    meta_file="${db_dir}meta.npy"

    if [[ ! -f "$db_file" || ! -f "$meta_file" ]]; then
        echo "[AVISO] Pulando $db_name — não achei db.npy/meta.npy" >&2
        continue
    fi

    for proteome in "$PROTEOMES_DIR"/*.faa; do
        proteome_name=$(basename "$proteome" .faa)
        out_file="$OUTPUT_DIR/${db_name}_${proteome_name}.tsv"
        printf "%s\t%s\t%s\t%s\n" "$db_file" "$meta_file" "$proteome" "$out_file" >> "$JOB_LIST"
    done
done

echo "Total gerado: $(wc -l < "$JOB_LIST")"

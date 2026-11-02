#!/bin/bash
# ==============================================================================
# DIAMOND blastx annotation of metagenomic reads
# ------------------------------------------------------------------------------
# Runs DIAMOND blastx for every combination of:
#     sample (torun/*_merged.fastq.gz)  x  protein database (.dmnd)
#
# Databases:
#     UNIREF  - HUMAnN 4 UniRef protein database (v2019_06, filtered)
#     DB1-DB6 - sialic acid metabolism databases
#
# For each database, results are written to DIAMOND_<DB>/ as <sample>.tsv
#
# Output columns (tabular, outfmt 6):
#     qseqid sseqid qlen slen length evalue bitscore qcovhsp pident ppos
#
# Logs (one pair per database, inside DIAMOND_<DB>/):
#     diamond_<DB>_errors.log  - DIAMOND stderr
#     diamond_<DB>_status.log  - one line per sample: SUCCESS or ERROR
# ------------------------------------------------------------------------------
# Configuration (edit the paths to match your system)
# ------------------------------------------------------------------------------
READS_DIR="./torun"
TMPDIR="/tmp/diamond_tmp"
THREADS=16

# database name -> .dmnd file
declare -A DBS=(
    [UNIREF]="/path/to/humann4_protein_database_filtered_v2019_06.dmnd"
    [DB1]="./DB1.dmnd"
    [DB2]="./DB2.dmnd"
    [DB3]="./DB3.dmnd"
    [DB4]="./DB4.dmnd"
    [DB5]="./DB5.dmnd"
    [DB6]="./DB6.dmnd"
)

mkdir -p "$TMPDIR" || {
    echo "Error creating temporary directory: $TMPDIR"
    exit 1
}

# ------------------------------------------------------------------------------
# Run DIAMOND
# ------------------------------------------------------------------------------
for db_name in UNIREF DB1 DB2 DB3 DB4 DB5 DB6; do
    db="${DBS[$db_name]}"
    outdir="DIAMOND_${db_name}"
    error_log="${outdir}/diamond_${db_name}_errors.log"
    status_log="${outdir}/diamond_${db_name}_status.log"

    mkdir -p "$outdir"

    for fq in "$READS_DIR"/*_merged.fastq.gz; do
        sample=$(basename "$fq" _merged.fastq.gz)

        echo "Processing ${sample} against ${db_name}..."

        # Remove leftover temporary files (if any)
        rm -f "${TMPDIR}"/diamond-tmp-*

        if diamond blastx \
            --query "$fq" \
            --db "$db" \
            --out "${outdir}/${sample}.tsv" \
            --outfmt 6 qseqid sseqid qlen slen length evalue bitscore qcovhsp pident ppos \
            --evalue 1.0 \
            --threads "$THREADS" \
            --top 1 \
            --iterate \
            --tmpdir "$TMPDIR" \
            2>>"$error_log"
        then
            echo -e "${sample}\tSUCCESS" >> "$status_log"
        else
            echo -e "${sample}\tERROR" >> "$status_log"
        fi
    done
done

#!/bin/bash
# ==============================================================================
# Metagenome functional annotation with MetaPhlAn + HUMAnN
# ------------------------------------------------------------------------------
# STEP 1 - Concatenate paired-end reads
#          <sample>_filtered_1_clean.fastq.gz + <sample>_filtered_2_clean.fastq.gz
#          -> <sample>_merged.fastq.gz
#          (HUMAnN does not use pairing information, so R1 and R2 are
#           concatenated into a single file per sample)
#
# STEP 2 - Taxonomic profiling with MetaPhlAn on each merged file
#          -> metaphlan_outputs/<sample>_profile.txt
#
# STEP 3 - Functional profiling with HUMAnN (standard protein database) on each
#          merged file, using the sample's MetaPhlAn profile
#          -> humann_outputs/<sample>/
#
# Usage:
#     bash run_humann_annotation.sh
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration (edit the paths to match your system)
# ------------------------------------------------------------------------------
READS_DIR="./cleaned_reads"
METAPHLAN_DB="/path/to/humann_databases/metaphlan"
METAPHLAN_INDEX="mpa_vOct22_CHOCOPhlAnSGB_202403"
METAPHLAN_OUT="./metaphlan_outputs"
HUMANN_OUT="./humann_outputs"

mkdir -p "$METAPHLAN_OUT" "$HUMANN_OUT"

# ==============================================================================
# STEP 1 - Concatenate paired-end reads
# ==============================================================================
for r1 in "$READS_DIR"/*_filtered_1_clean.fastq.gz; do
    base=${r1%_filtered_1_clean.fastq.gz}
    r2="${base}_filtered_2_clean.fastq.gz"

    cat "$r1" "$r2" > "${base}_merged.fastq.gz"
done

# ==============================================================================
# STEP 2 - MetaPhlAn
# ==============================================================================
for f in "$READS_DIR"/*_merged.fastq.gz; do
    base=$(basename "$f" _merged.fastq.gz)

    metaphlan "$f" \
        --input_type fastq \
        --bowtie2db "$METAPHLAN_DB" \
        --index "$METAPHLAN_INDEX" \
        --offline \
        --nproc 5 \
        -t rel_ab_w_read_stats \
        -o "${METAPHLAN_OUT}/${base}_profile.txt"
done

# ==============================================================================
# STEP 3 - HUMAnN (standard protein database)
# ==============================================================================
for f in "$READS_DIR"/*_merged.fastq.gz; do
    base=$(basename "$f" _merged.fastq.gz)

    humann \
        --input "$f" \
        --output "${HUMANN_OUT}/${base}" \
        --taxonomic-profile "${METAPHLAN_OUT}/${base}_profile.txt" \
        --threads 8
done

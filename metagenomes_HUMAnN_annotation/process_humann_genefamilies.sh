#!/bin/bash
# ==============================================================================
# Processing HUMAnN gene family tables
# ------------------------------------------------------------------------------
# Gene families (UniRef) are regrouped into functional categories before
# normalization, as recommended in the HUMAnN user manual:
#   "Alternatively, gene families can be regrouped to different functional
#    categories prior to normalization"
#
# STEP 1 - Regroup each <sample>_genefamilies.tsv
#            by KEGG Orthology (KO)  -> regrouped_ko/<sample>_ko.tsv
#            by Enzyme Commission (EC) number -> regrouped_ec/<sample>_ec.tsv
#
# STEP 2 - Normalize each regrouped table to relative abundance (relab)
#            -> regrouped_ko_relab/<sample>_ko_relab.tsv
#            -> regrouped_ec_relab/<sample>_ec_relab.tsv
#
# STEP 3 - Join all samples into a single table per category
#            -> humann_genefamilies_ko_relab.tsv
#            -> humann_genefamilies_ec_relab.tsv
#
# Usage (run inside the HUMAnN output folder):
#     bash process_humann_genefamilies.sh
# ==============================================================================

HUMANN_OUT="./humann_outputs"

mkdir -p regrouped_ko regrouped_ec regrouped_ko_relab regrouped_ec_relab

# ==============================================================================
# STEP 1 - Regroup gene families by KO and by EC number
# ==============================================================================
find "$HUMANN_OUT" -type f -name "*_genefamilies.tsv" | while read -r file; do
    sample=$(basename "$file" "_genefamilies.tsv")
    echo "Regrouping $sample"

    humann_regroup_table \
        --input "$file" \
        --groups uniref90_ko \
        --output "regrouped_ko/${sample}_ko.tsv"

    humann_regroup_table \
        --input "$file" \
        --groups uniclust90_level4ec \
        --output "regrouped_ec/${sample}_ec.tsv"
done

# ==============================================================================
# STEP 2 - Normalize to relative abundance
# ==============================================================================
for file in regrouped_ko/*_ko.tsv; do
    sample=$(basename "$file" "_ko.tsv")
    echo "Normalizing KO table: $sample"

    humann_renorm_table \
        --input "$file" \
        --output "regrouped_ko_relab/${sample}_ko_relab.tsv" \
        --units relab
done

for file in regrouped_ec/*_ec.tsv; do
    sample=$(basename "$file" "_ec.tsv")
    echo "Normalizing EC table: $sample"

    humann_renorm_table \
        --input "$file" \
        --output "regrouped_ec_relab/${sample}_ec_relab.tsv" \
        --units relab
done

# ==============================================================================
# STEP 3 - Join all samples
# ==============================================================================
humann_join_tables \
    --input regrouped_ko_relab \
    --output humann_genefamilies_ko_relab.tsv \
    --file_name _ko_relab.tsv

humann_join_tables \
    --input regrouped_ec_relab \
    --output humann_genefamilies_ec_relab.tsv \
    --file_name _ec_relab.tsv

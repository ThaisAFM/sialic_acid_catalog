# https://github.com/flatironinstitute/deepblast/wiki/Building-the-TMvec-search-database

INPUT_DIR="./DB6_nr60"
MODEL="tm_vec_cath_model_large.ckpt"
CONFIG="49181518_tm_vec_cath_model_large_params.json"
PROTRANS="Rostlab/prot_t5_xl_uniref50"
LOG="tmvec_run_log.txt"

for fasta in "$INPUT_DIR"/*_DB6_nr60.fasta; do
    gene=$(basename "$fasta" _DB6_nr60.fasta)
    output="${gene}_DB6_tmvec_database"

    echo "===== Iniciando: $gene =====" | tee -a "$LOG"
    start=$(date +%s)

    tmvec-build-database \
        --input-fasta "$fasta" \
        --tm-vec-model "$MODEL" \
        --tm-vec-config-path "$CONFIG" \
        --device cpu \
        --output "$output" \
        --protrans-model "$PROTRANS" \
        2>&1 | tee -a "$LOG"

    end=$(date +%s)
    elapsed=$((end - start))
    echo "===== Concluído: $gene em ${elapsed}s =====" | tee -a "$LOG"
    echo "" | tee -a "$LOG"
done

proteomes_dir="proteomes"
db_dir="./"
 
# list of databases (without the .dmnd extension)
dbs=("DB1" "DB2" "DB3" "DB4" "DB5" "DB6")
 
for db in "${dbs[@]}"; do
 
    mkdir -p results_$db
 
    for proteome in ${proteomes_dir}/*.faa; do
 
        base=$(basename "$proteome" .faa)
 
        diamond blastp \
            --query "$proteome" \
            --db "$db_dir/$db.dmnd" \
            --out "results_$db/${base}_${db}.outfmt6" \
            --outfmt 6 qseqid sseqid qlen slen length evalue bitscore qcovhsp pident ppos \
            --max-target-seqs 1 \
            --threads 16
 
    done
done

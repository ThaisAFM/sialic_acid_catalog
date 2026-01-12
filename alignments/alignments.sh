# In a directory containing all FASTA files from the local database, already recoded and merged across databases,
# together with all FASTA files for the reference sequences,
# DIAMOND is used to align the local database sequences against their respective reference sequences.
# The command is configured to report only the best hit.

for f in *.fasta; do
    gene=$(echo "$f" | cut -d'_' -f1)   # just take the name of the gene before the first “_”
    db="${gene}_ref.dmnd"
    
    if [[ -f "$db" ]]; then
        echo "Running for $f using database $db..."
        diamond blastp \
            --query "$f" \
            --more-sensitive \
            --evalue 0.001 \
            --max-target-seqs 1 \
            --max-hsps 1 \
            --db "$db" \
            --out "${f%.fasta}.outfmt6" \
            --outfmt 6 qseqid sseqid pident ppos length evalue bitscore qlen slen
    else
        echo " !! $db database NOT FOUND, skipping $f."
    fi
done

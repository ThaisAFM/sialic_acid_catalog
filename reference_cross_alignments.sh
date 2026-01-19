# The reference FASTA files had already been converted into DIAMOND database format 
# using makedb.sh within the alignments folder. 
# These database files and the original reference FASTA sequences were then used 
# to run the following DIAMOND loop. 
# In this configuration, the search was set to report all target sequences per query 
# while retaining only one high-scoring segment pair (HSP) per hit, 
# allowing the evaluation of alignments across all reference sequences.

for f in *.fasta; do
    gene=$(echo "$f" | cut -d'_' -f1)   # gets only the gene name before the first "_"
    db="${gene}_ref.dmnd"
    
    if [[ -f "$db" ]]; then
        echo "Running for $f using database $db..."
        diamond blastp \
            --query "$f" \
            --more-sensitive \
            --evalue 0.001 \
            --max-target-seqs 0 \
            --max-hsps 1 \
            --db "$db" \
            --out "${f%.fasta}.outfmt6" \
            --outfmt 6 qseqid sseqid pident ppos length evalue bitscore qlen slen
    else
        echo "⚠️ Database $db not found, skipping $f."
    fi
done

# In the directory containing the reference sequence files, all FASTA files were converted into DIAMOND database format

for fasta in *.fasta; do
    gene=$(basename "$fasta" | cut -d'_' -f1)
    diamond makedb --in "$fasta" -d "$gene"
done

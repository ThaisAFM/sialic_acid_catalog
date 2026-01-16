# In the directory containing the reference sequence files, all FASTA files were converted into DIAMOND database format

for fasta in *_ref.fasta; do
    base=$(basename "$fasta" .fasta)
    diamond makedb --in "$fasta" -d "$base"
done

# In the directory containing the reference sequence files, all FASTA files were converted into DIAMOND database format

# diretorio: /media/Data/thais/sialic_acid_catalog/banco_de_dados/redo_all/refs

for fasta in *_ref.fasta; do
    base=$(basename "$fasta" .fasta)
    diamond makedb --in "$fasta" -d "$base"
done

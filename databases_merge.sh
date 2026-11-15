# With all recoded FASTA files from different databases (gene_database_coded.fasta) placed in the same directory, apply the following command to concatenate files corresponding to the same gene into a single file

# diretório: /media/Data/thais/sialic_acid_catalog/banco_de_dados/coded

for gene in $(ls *.fasta | cut -d'_' -f1 | sort -u); do
    cat ${gene}_*.fasta > ${gene}_merged.fasta
done

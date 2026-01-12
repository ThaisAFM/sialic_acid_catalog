# With all recoded FASTA files from different databases (gene_database_coded.fasta) placed in the same directory, apply the following command to concatenate files corresponding to the same gene into a single file

for gene in $(ls *.fasta | cut -d'_' -f1 | sort -u); do
    cat ${gene}_*.fasta > ${gene}_merged.fasta
done

### Running CD-HIT for All FASTA Files

# The following command iterates through all FASTA files in the current folder and applies the **CD-HIT** clustering algorithm to each one.  
# It generates:  
# A `.clstr` file containing the clusters of redundant sequences at **100% identity**.  
# A FASTA file containing only the representative sequence for each cluster.

```bash
for arquivo in *.fasta; do
    saida="${arquivo%.fasta}_nr100"
    cd-hit -i "$arquivo" -o "$saida" -c 1.00 -n 5 -M 2000
    echo "Processed: $arquivo -> ${saida}"
done

# Iterate through all FASTA files and run CD-HIT at 100% identity

# It generates:  
# A `.clstr` file containing the clusters of redundant sequences at **100% identity**.  
# A FASTA file containing only the representative sequence for each cluster.

for arquivo in *.fasta; do
    saida="${arquivo%.fasta}_nr100"
    cd-hit -i "$arquivo" -o "$saida" -c 1.00 -n 5 -M 2000
    echo "Processed: $arquivo -> ${saida}"
done

# Organazing the files:
# Move all non-redundant FASTA files to a dedicated folder
# and rename them to simplify the next steps

mkdir fastas_nr
cp *nr100 fastas_nr
cd fastas_nr
rename 's/_nr100$/.fasta/' * 

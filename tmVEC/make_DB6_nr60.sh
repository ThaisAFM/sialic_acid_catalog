#diretorio = /media/Data/thais/sialic_acid_catalog/banco_de_dados/final_fastas/FASTAS_without_extra_aligned

for file in *.fasta; do
    output="${file%.fasta}_nr60.fasta"
    cd-hit -i "$file" -o "$output" -c 0.6 -n 4 -M 4000
    echo "Processed: $file -> $output"
done

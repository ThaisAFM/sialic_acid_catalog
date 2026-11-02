for file in *.fasta; do
    output="${file%.fasta}_nr60.fasta"
    cd-hit -i "$file" -o "$output" -c 0.6 -n 4 -M 4000
    echo "Processed: $file -> $output"
done

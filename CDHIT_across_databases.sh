# After moving all concatenated files to a dedicated directory, run CD-HIT to remove redundancy and identify sequence clusters

for arquivo in *.fasta; do saida="${arquivo%.fasta}_nr" cd-hit -i "$arquivo" -o "$saida" -c 1.00 -n 5 -M 2000 echo "Processado: $arquivo -> ${saida}" done

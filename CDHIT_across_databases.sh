# After moving all concatenated files to a dedicated directory, run CD-HIT to remove redundancy and identify sequence clusters

# diretório: /media/Data/thais/sialic_acid_catalog/banco_de_dados/databases_merge/merged

for arquivo in *.fasta; do saida="${arquivo%.fasta}_nr" cd-hit -i "$arquivo" -o "$saida" -c 1.00 -n 5 -M 2000 echo "Processado: $arquivo -> ${saida}" done

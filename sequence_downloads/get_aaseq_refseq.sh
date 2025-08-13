##!/usr/bin/env bash
## Use of NCBI API (entrez) to retrieve protein sequences from RefSeq

# You can use a loop to iterate through a list of genes

esearch -db protein -query <gene> | efilter -organism bacteria -source refseq | efetch -format fasta >> <gene>_refseq.fasta

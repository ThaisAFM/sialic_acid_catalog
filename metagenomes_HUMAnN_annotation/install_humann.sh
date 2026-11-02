# creating the environment and configuring the channels  

conda create -n humann4 python=3.12 -y
conda activate humann4

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --add channels biobakery

# installing human and metaplan compatible versions 

mamba install humann=4.0 metaphlan=4.0 -c biobakery

# downloading and setting the databases 

humann_databases --download uniref uniref90_ec_filtered_diamond .
humann_databases --download chocophlan full .
humann_databases --download utility_mapping full .
humann_config --update database_folders nucleotide /media/Spock/humann_databases/chocophlan/
humann_config --update database_folders protein /media/Spock/humann_databases/uniref/
humann_config --update database_folders utility_mapping /media/Spock/humann_databases/utility_mapping

# install metaphlan

metaphlan --install \
--index mpa_vOct22_CHOCOPhlAnSGB_202403 \
--bowtie2db /media/Spock/humann_databases/metaphlan

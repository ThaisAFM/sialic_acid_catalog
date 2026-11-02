# tmVEC documentation: https://github.com/tymor22/tm-vec/tree/master

conda create -n tmvec faiss-cpu python=3.9 -c pytorch
conda activate tmvec
pip install tm-vec

mkdir Rostlab && cd "$_"
wget https://zenodo.org/record/4644188/files/prot_t5_xl_uniref50.zip
unzip prot_t5_xl_uniref50.zip
cd ..

# download all https://figshare.com/s/e414d6a52fd471d86d69 files, and unzip them in your working directory (before Rostlab)

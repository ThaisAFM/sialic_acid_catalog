# -*- coding: utf-8 -*-
"""get_aaseq_kegg.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1hDcUE6WETxWUhzxR1t_eLt4e2_r053Ay

## Use of KEGG API to retrieve protein sequences

The API is built with Python

Submit the job with the sbatch command

You can loop through a list of genes, but there's a risk of reaching the KEGG’s request limit
"""

#!/bin/bash
#SBATCH --job-name=job_name
#SBATCH --partition=SP2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=24:00:00
#SBATCH --mem-per-cpu=24042
#SBATCH --mail-type=BEGING,END
#SBATCH --mail-user= e-mail

module load Miniconda/3

python - <<EOF

import requests # This line of code makes the requests library available for use
                # within the current Python script or notebook.

"""### Bacterial codes

In this section, the KEGG API list operation is used to collect all codes refering to bacterial organisms avaiable on KEGG.
"""

# Extracting a list of all organisms avaiable on KEGG

url_list_org = f'https://rest.kegg.jp/list/organism' # List of all organisms in KEGG
orgs = requests.get(url_list_org) # Make the GET request
org_list = orgs.text.splitlines() # chops the text block into individual lines and stores those lines in a list

# Filtering all bacterial organisms in KEGG
bacteria_list = [item for item in org_list if 'bacteria' in item.lower()]
print(bacteria_list)

# Extracting the codes for the bacterial organisms
bacterial_codes = [item.split('\t')[1] for item in bacteria_list]
print(bacterial_codes)

"""### Amino acid sequences

In this section, the KEGG API get operation is used to collect the amino acid sequences for a specific gene across all bacterial organ$
"""
# ACCORDING TO KEGG API, CODE MUST HAVE THE FOLLOWING FORMAT:
# http://rest.kegg.jp/get/<org>:<gene>/aaseq

# The following code iterates through a list of organisms, fetches protein sequence data for a specific gene from
# the KEGG database using their API, and saves the retrieved data to a file if the request is successful.
# If there is an error, it prints the error status code.

def get_aaseq(gene):
  for code in bacterial_codes:
    url = f"http://rest.kegg.jp/get/{code}:{gene}/aaseq"
    response = requests.get(url)

    if response.status_code == 200:
      response = response.text
      with open(f'kegg_{gene}.txt', 'a') as f:
          f.write(response)
    else:
      print(response.status_code)

# Applying the function

get_aaseq('<your_gene>')

EOF
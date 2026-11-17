This folder contains the scripts required to perform the complete TM-Vec analysis.

First, remove redundancy from the database using make_DB6_nr60.sh and install TM-Vec by running install_tmvec.sh. Next, generate the TM-Vec vector database using tmvec_build_database.sh.

Then, generate the job list with make_job_list.sh. The resulting file should be used as input for the tmvec_search.sh script. The tmvec_status.csv file, required to run the search script, is also provided in this directory.

Finally, filter and visualize the results using the tmvec_hits_summary.ipynb.

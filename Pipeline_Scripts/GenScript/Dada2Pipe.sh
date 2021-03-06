#!/bin/bash 

# $1 name of the config file.
# $2 name of data set
# $3 filter stringencies
# $4 number of threads

source activate dada2
echo "*********************************************** Running Dada2 Pipeline ****************************************"

echo "Reading in " $1

readarray -t vars <$1

echo ${vars[1]}

if [ ${vars[0]} -eq 1 ]; then
       echo "Removing old data"
       rm -rf ../../../DenoiseCompare_Out/${vars[1]}/$2/dada2
fi
					
cd ../../../DenoiseCompare_Out/${vars[1]}/$2

mkdir dada2

cd dada2


echo "*********************Getting Error Rates*********************"

dada2_inference.R -f ../filtered_fastqs/ --seed 1995 -t ${vars[3]} --verbose

echo "****************************************** Chimera Checking Assigning Taxonomy *******************************"
dada2_chimera_taxa.R -i seqtab.rds -r ~/etc/databases/rdp_train_set_16.fa --skip_species -t ${vars[3]}

echo "****************************************** Converting to BIOM and Fasta **************************************"
convert_dada2_out.R -i \
		    seqtab_final.rds -b seqtab.biom -f seqtab.fasta --taxa_in tax_final.rds

source activate qiime1

echo "************************************Summarize biom file and Rarifying to highest depth possible****************************"
biom summarize-table -i seqtab.biom -o seqtab_summary.txt



#get lowest number of reads in a sample and rarify
rare="$(cat seqtab_summary.txt | awk 'NR >= 16 { print }' | awk -F" " '{print $2}' | head -1)"
rarefix=${rare/.0/}
single_rarefaction.py -i seqtab.biom -o seqtab_rare.biom -d $rarefix



cd /media/jacob/Storage/Rule_them_all/
echo "*******************FOR 16S DATA************************"

echo "**************** Running Dada2 With Medium Strigencies ******************************"
read -p "Directory of 16S Data: " DataDir
read -p "Number of Paired Samples: " sNum
read -p "Output Directory: " Out

source activate qiime1

echo "********* Cutting Primers (Primers are cut for all Pipelines)***********"

mkdir $Out/primer_trimmed_fastqs

parallel --link --jobs $sNumber \
  'cutadapt \
    --pair-filter any \
    --no-indels \
    --discard-untrimmed \
    -g ACGCGHNRAACCTTACC \
    -G ACGGGCRGTGWGTRCAA \
    -o primer_trimmed_fastqs/{1/}.gz \
    -p primer_trimmed_fastqs/{2/}.gz \
    {1} {2} \
    > primer_trimmed_fastqs/{1/}_cutadapt_log.txt' \
  ::: *R1*.fastq ::: *R2*.fastq
cd $Out
parse_cutadapt_logs.py -i primer_trimmed_fastqs/*log.txt
cd ..

echo "*********Filtering Reads******************" 
dada2_filter.R -f primer_trimmed_fastqs --truncLen 270,210 --maxN 0 --maxEE 3,7 --truncQ 2 --threads $sNumber --f_match R1.*fastq.* --r_match R2.fastq.*


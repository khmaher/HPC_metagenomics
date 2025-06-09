#!/bin/bash

src=$1

# make new directory for kraken output
mkdir $src/bracken

# run bracken

for f in $src/kraken2/*.kreport2;
do FBASE=$(basename $f)
        BASE=${FBASE%.kreport2}
        samtools flagstat $src/aligned/${BASE}.bam > $src/flagstat/${BASE}.flagstat
        bracken -d /usr/local/extras/Genomics/db/kraken2/kraken2_db -i $src/kraken2/${BASE}.kreport2 -o $src/bracken/${BASE}.bracken -w $src/kraken2/${BASE}.breport2 -r 150 -l S -t 10 
done

# Merge Bracken output

mkdir $src/bracken_all

combine_bracken_outputs.py --files $src/bracken/*.bracken -o $src/bracken_all/all.bracken

# Extract Bracken output
#Create variable
# Final number in the seq (89) must be 3 + 2*number of samples you have

bracken_num_columns=$(seq -s , 4 2 89)
echo $bracken_num_columns

cat $src/bracken_all/all.bracken | cut -f 1,$bracken_num_columns > $src/bracken_all/all_num.bracken

#!/bin/bash

#SBATCH --job-name=10_humann
#SBATCH --output=10_humann.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=168:00:00

source ~/.bashrc

conda activate biobakery3.9


src=$PWD

# make new directory for human output
mkdir $src/cat_files
mkdir $src/humann


# cat files

for f in $src/trim/*_trimmed_paired_R1.fastq.gz;
do              FBASE=$(basename $f)
        BASE=${FBASE%_trimmed_paired_R1.fastq.gz}
        cat $src/trim/${BASE}_trimmed_paired_R1.fastq.gz \
	$src/trim/${BASE}_trimmed_paired_R2.fastq.gz > \
	$src/cat_files/${BASE}_trimmed_paired.fastq.gz
done

# run humann

for f in $src/cat_files/*_trimmed_paired.fastq.gz;
do              FBASE=$(basename $f)
        BASE=${FBASE%_trimmed_paired.fastq.gz}
        humann --input $src/cat_files/${BASE}_trimmed_paired.fastq.gz \
	--output $src/humann/${BASE}_humann_output \
	--threads 12 
done

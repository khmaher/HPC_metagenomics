#!/bin/bash

#SBATCH --job-name=09_humann
#SBATCH --output=09_humann.log
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

for f in $src/deacon/*_hostDepleted_R1.fq.gz;
do              FBASE=$(basename $f)
        BASE=${FBASE%_hostDepleted_R1.fq.gz}
        cat $src/deacon/${BASE}_hostDepleted_R1.fq.gz \
	$src/deacon/${BASE}_hostDepleted_R2.fq.gz > \
	$src/cat_files/${BASE}_hostDepleted_paired.fastq.gz
done

# run humann

for f in $src/cat_files/*_hostDepleted_paired.fastq.gz;
do              FBASE=$(basename $f)
        BASE=${FBASE%_hostDepleted_paired.fastq.gz}
        humann --input $src/cat_files/${BASE}_hostDepleted_paired.fastq.gz \
	--output $src/humann/${BASE}_humann_output \
	--threads 12 
done

#!/bin/bash

#SBATCH --job-name=06_remove_host
#SBATCH --output=06_remove_host.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -A molecolb
#SBATCH -p molecolb
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=72:00:00

source ~/.bash_profile

src=$PWD

# make new directories for flagstat reports and cleaned bam files
mkdir $src/flagstat
mkdir $src/host_removed

# run flagstat to check mapping efficiency
# use samtools to extract all unmapped reads from the bam
# re-pair the reads by removing reads with a missing pair. The command ensures the order of the reads are identical in the 2 output paired files

for f in $src/aligned/*.bam;
do FBASE=$(basename $f)
	BASE=${FBASE%.bam}
	samtools flagstat $src/aligned/${BASE}.bam > $src/flagstat/${BASE}.flagstat
	samtools fastq -f 4 -1 $src/host_removed/${BASE}_R1.u.fastq -2 $src/host_removed/${BASE}_R2.u.fastq $src/aligned/${BASE}.bam
	repair.sh in1=$src/host_removed/${BASE}_R1.u.fastq in2=$src/host_removed/${BASE}_R2.u.fastq out1=$src/host_removed/${BASE}_R1.final.fastq out2=$src/host_removed/${BASE}_R2.final.fastq outs=$src/host_removed/${BASE}_singletons.fastq
done

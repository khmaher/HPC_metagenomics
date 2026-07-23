#!/bin/bash

#SBATCH --job-name=13_genome.binning
#SBATCH --output=13_genome.binning.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=168:00:00

source ~/.bashrc
conda activate /usr/local/community/Genomics/apps/mambaforge/envs/shotgun_meta


src=$PWD

# make a new directory
mkdir $src/binning
mkdir $src/bins

# run metaBAT2

for f in $src/MEGAHIT_assembly/*;
do FBASE=$(basename $f)
	mkdir $src/binning/${FBASE}
	bwa index $src/MEGAHIT_assembly/${FBASE}/final.contigs.fa
	bwa mem -t 10 $src/MEGAHIT_assembly/${FBASE}/final.contigs.fa \
	$src/deacon/${FBASE}_hostDepleted_R1.fq.gz $src/deacon/${FBASE}_hostDepleted_R2.fq.gz | \
	samtools sort -O BAM -o $src/binning/${FBASE}/${FBASE}.sort.bam
	jgi_summarize_bam_contig_depths --outputDepth $src/binning/${FBASE}/${FBASE}.depth.txt $src/binning/${FBASE}/${FBASE}.sort.bam
	metabat2 \
	--inFile $src/binning/${FBASE}/final.contigs.fa \
	--outFile bins/${FBASE} \
	--abdFile $src/binning/${FBASE}/${FBASE}.depth.txt \
	--minContig 2500
done

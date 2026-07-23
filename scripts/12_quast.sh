#!/bin/bash

#SBATCH --job-name=12_quast
#SBATCH --output=12_quast.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=12GB
#SBATCH --time=24:00:00

source ~/.bashrc
conda activate /usr/local/community/Genomics/apps/mambaforge/envs/shotgun_meta

src=$PWD

# make new directory for QUAST output
mkdir $src/quast

# run QUAST

for f in $src/MEGAHIT_assembly/*;
do FBASE=$(basename $f)
	mkdir $src/quast/${FBASE}
	quast -o $src/quast/${FBASE} $src/MEGAHIT_assembly/${FBASE}/final.contigs.fa
done

#!/bin/bash

#SBATCH --job-name=10_flash
#SBATCH --output=10_flash.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem-per-cpu=6GB
#SBATCH --time=:00:00

source ~/.bashrc
conda activate /usr/local/community/Genomics/apps/mambaforge/envs/shotgun_meta


src=$PWD

# make new directory for merged reads
mkdir $src/stitched

# run flash to join reads

for f in $src/deacon/*_hostDepleted_R1.fq.gz;
do FBASE=$(basename $f)
	BASE=${FBASE%_hostDepleted_R1.fq.gz} 
	flash -o ${BASE} -z -t 10 -d $src/stitched $src/deacon/${BASE}_hostDepleted_R1.fq.gz $src/deacon/${BASE}_hostDepleted_R2.fq.gz
done

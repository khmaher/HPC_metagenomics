#!/bin/bash

#SBATCH --job-name=11_megahit
#SBATCH --output=11_megahit.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem-per-cpu=6GB
#SBATCH --time=72:00:00

source ~/.bashrc
conda activate /usr/local/community/Genomics/apps/mambaforge/envs/shotgun_meta

helpFunction()
{
   echo ""
   echo "Usage: $0 -k parameterK"
   echo -e "\t-k K-mer list"
   exit 1 # Exit script after printing help
}

while getopts "k:" opt
do
   case "$opt" in
      k ) parameterK="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterK" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

src=$PWD

# make new directory for your megahit assembly
mkdir $src/MEGAHIT_assembly

# run flash to join reads

for f in $src/stitched/${BASE}.extendedFrags.fastq.gz;
do FBASE=$(basename $f)
	BASE=${FBASE%.extendedFrags.fastq.gz} 
	megahit \
	-r $src/stitched/${BASE}.extendedFrags.fastq.gz \
	-1 $src/stitched/${BASE}.notCombined_1.fastq.gz \
	-2 $src/stitched/${BASE}.notCombined_2.fastq.gz \
	-o $src/MEGAHIT_assembly/${BASE} \
	-t 10 \
	--k-list $parameterK
done




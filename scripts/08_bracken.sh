#!/bin/bash

#SBATCH --job-name=08_bracken
#SBATCH --output=08_bracken.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=1:00:00

source ~/.bashrc
conda activate shotgun_meta

helpFunction()
{
   echo ""
   echo "Usage: $0 -d parameterD -r parameterR -l parameterL -t parameterT -s parameterS"
   echo -e "\t-d the Kraken2 database that was used for taxonomic classification"
   echo -e "\t-r the ideal length of the reads that were used in the Kraken2 classification"
   echo -e "\t-l the taxonomic level/rank of the Bracken output"
   echo -e "\t-t the minimum number of reads required for a classification at the specified rank"
   exit 1 # Exit script after printing help
}

while getopts "d:r:l:t:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      r ) parameterR="$OPTARG" ;;
      l ) parameterL="$OPTARG" ;;
      t ) parameterT="$OPTARG" ;;
      #? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterD" ] || [ -z "$parameterR" ] || [ -z "$parameterL" ] || [ -z "$parameterT" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# run command
src=$PWD

# make new directory for kraken output
mkdir $src/bracken

# run bracken

for f in $src/kraken2/*.kreport2;
do FBASE=$(basename $f)
        BASE=${FBASE%.kreport2}
        bracken -d $parameterD -i $src/kraken2/${BASE}.kreport2 -o $src/bracken/${BASE}.bracken -w $src/bracken/${BASE}.breport2 -r $parameterR -l $parameterL -t $parameterT

done

# Merge Bracken output

mkdir $src/bracken_all

combine_bracken_outputs.py --files $src/bracken/*.bracken -o $src/bracken_all/all.bracken

# Convert Bracken output to biom

kraken-biom $src/bracken/*breport2 -o $src/bracken/All_samples.biom

# Create tsv (tab separated value) file for manual inspection.

biom convert -i $src/bracken/All_samples.biom -o $src/bracken/All_samples.tsv --header-key taxonomy --to-tsv

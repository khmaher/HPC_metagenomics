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
   echo -e "\t-s The number S is chosen as 3 (first three info columns) + X*2 (X samples with 2 columns each) = S"
   exit 1 # Exit script after printing help
}

while getopts "d:r:l:t:s:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      r ) parameterR="$OPTARG" ;;
      l ) parameterL="$OPTARG" ;;
      t ) parameterT="$OPTARG" ;;
      s ) parameterS="$OPTARG" ;;
      #? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterD" ] || [ -z "$parameterR" ] || [ -z "$parameterL" ] || [ -z "$parameterT" ] || [ -z "$parameterS" ]
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
        bracken -d $parameterD -i $src/kraken2/${BASE}.kreport2 -o $src/bracken/${BASE}.bracken -w $src/kraken2/${BASE}.breport2 -r $parameterR -l $parameterL -t $parameterT

done

# Merge Bracken output

mkdir $src/bracken_all

combine_bracken_outputs.py --files $src/bracken/*.bracken -o $src/bracken_all/all.bracken

# Extract Bracken output
#Create variable
# Final number in the seq must be 3 + 2*number of samples you have

bracken_num_columns=$(seq -s , 4 2 $parameterS)
echo $bracken_num_columns

cat $src/bracken_all/all.bracken | cut -f 1,$bracken_num_columns > $src/bracken_all/all_num.bracken

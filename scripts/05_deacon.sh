#!/bin/bash

#SBATCH --job-name=05_host_removal
#SBATCH --output=05_host_removal.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH -A molecolb
#SBATCH -p molecolb
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=24:00:00

source ~/.bash_profile
conda activate /usr/local/community/Genomics/apps/mambaforge/envs/deacon

helpFunction()
{
   echo ""
   echo "Usage: $0 -g parameterG"
   echo -e "\t-f the name of your reference genome"
   exit 1 # Exit script after printing help
}

while getopts "g:" opt
do
   case "$opt" in
      g ) parameterG="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterG" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi


src=$PWD

# make directories
mkdir $src/deacon

# index genome
deacon index build $src/genome/$parameterG > $src/genome/$parameterG.idx


# run deacon to remove host sequences

for f in $src/trim/*_trimmed_paired_R1.fastq.gz;
do FBASE=$(basename $f)
        BASE=${FBASE%_trimmed_paired_R1.fastq.gz}
        deacon filter -t 8 -d $src/genome/$parameterG.idx $src/trim/${BASE}_trimmed_paired_R1.fastq.gz \
        $src/trim/${BASE}_trimmed_paired_R2.fastq.gz \
        -o $src/deacon/${BASE}_hostDepleted_R1.fq.gz -O $src/deacon/${BASE}_hostDepleted_R2.fq.gz
done

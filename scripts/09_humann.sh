#!/bin/bash

#SBATCH --job-name=09_humann
#SBATCH --output=09_humann.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=96:00:00

source ~/.bashrc

conda activate biobakery3.9

helpFunction()
{
   echo ""
   echo "Usage: $0 -d parameterD -f parameterF -r parameterR"
   echo -e "\t-d the directory containing your input data files"
   echo -e "\t-f the file extension for your forward reads"
   echo -e "\t-r the file extension for your reverse reads"
   exit 1 # Exit script after printing help
}

while getopts "d:f:r:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
	  f ) parameterF="$OPTARG" ;;
      r ) parameterR="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterD" ] || [ -z "$parameterF" ] || [ -z "$parameterR" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi


src=$PWD

# make new directory for human output
mkdir $src/cat_files
mkdir $src/humann


# cat files

for f in $src/$parameterD/*$parameterF;
do              FBASE=$(basename $f)
        BASE=${FBASE%$parameterF}
        cat $src/$parameterD/${BASE}$parameterF \
	$src/$parameterD/${BASE}$parameterR > \
	$src/cat_files/${BASE}_paired.fastq.gz
done

# run humann

for f in $src/cat_files/*_paired.fastq.gz;
do              FBASE=$(basename $f)
        BASE=${FBASE%_paired.fastq.gz}
        humann --input $src/cat_files/${BASE}_paired.fastq.gz \
	--output $src/humann/${BASE}_humann_output \
	--threads 20 
done

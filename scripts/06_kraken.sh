#!/bin/bash

#SBATCH --job-name=06_kraken
#SBATCH --output=06_kraken.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=48:00:00

source ~/.bashrc
conda activate shotgun_meta


helpFunction()
{
   echo ""
   echo "Usage: $0 -k parameterK -d parameterD -f parameterF -r parameterR"
   echo -e "\t-k the location of your Kraken database"
   echo -e "\t-d the directory containing your input data files"
   echo -e "\t-f the file extension for your forward reads"
   echo -e "\t-r the file extension for your reverse reads"
   exit 1 # Exit script after printing help
}

while getopts "k:d:f:r:" opt
do
   case "$opt" in
   	  k ) parameterK="$OPTARG" ;;
      d ) parameterD="$OPTARG" ;;
	  f ) parameterF="$OPTARG" ;;
      r ) parameterR="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterK" ] || [ -z "$parameterD" ] || [ -z "$parameterF" ] || [ -z "$parameterR" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi


src=$PWD

# make new directory for kraken output
mkdir $src/kraken2

# run kraken2

for f in $src/deacon/*_hostDepleted_R1.fq.gz;
do FBASE=$(basename $f)
	BASE=${FBASE%_hostDepleted_R1.fq.gz} 
	kraken2 --threads 20 --paired --db $parameterK --output $src/kraken2/${BASE}.kraken --report $src/kraken2/${BASE}.kreport2 $src/$parameterD/${BASE}_hostDepleted_R1.fq.gz $src/$parameterD/${BASE}_hostDepleted_R2.fq.gz
done


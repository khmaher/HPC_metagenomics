#!/bin/bash

#SBATCH --job-name=06_kraken
#SBATCH --output=06_kraken.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=48:00:00
#SBATCH -A molecolb
#SBATCH -p molecolb

source ~/.bashrc
conda activate shotgun_meta


helpFunction()
{
   echo ""
   echo "Usage: $0 -d parameterD"
   echo -e "\t-d the location of your Kraken database"
   exit 1 # Exit script after printing help
}

while getopts "d:" opt
do
   case "$opt" in
      d ) parameterD="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$parameterD" ]
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
	kraken2 --threads 20 --paired --db $parameterD --output $src/kraken2/${BASE}.kraken --report $src/kraken2/${BASE}.kreport2 $src/deacon/${BASE}_hostDepleted_R1.fq.gz $src/deacon/${BASE}_hostDepleted_R2.fq.gz
done


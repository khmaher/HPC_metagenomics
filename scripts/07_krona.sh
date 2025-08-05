#!/bin/bash

#SBATCH --job-name=07_krona
#SBATCH --output=07_krona.log
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=1:00:00

source ~/.bashrc
conda activate shotgun_meta


src=$PWD

# make new directory for kraken output
mkdir $src/krona

# run krona

ktImportTaxonomy -o $src/krona/kraken2.krona.html $src/kraken2/*.kreport2

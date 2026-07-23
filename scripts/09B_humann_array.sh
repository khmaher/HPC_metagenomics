#!/bin/bash

#SBATCH --job-name=09B_humann_array
#SBATCH --output=09B_humann_%a_o%j
#SBATCH --error=09B_humann_%a_e%j
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --mem=6G
#SBATCH --mail-type=END
#SBATCH --mail-user=user@uni.ac.uk

# source software

source ~/.bashrc
conda activate biobakery3.9

src=$PWD

CONCAT_DIR=$src/cat_files
OUTPUT_DIR=$src/humann
MANIFEST="sample_chunks.tsv"

# make output directory

mkdir $OUTPUT_DIR

# Read the specific line corresponding to this array task ID
CHUNK_LINE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$MANIFEST")

# Convert tab-separated line into an array of sample names
IFS=$'\t' read -r -a SAMPLES <<< "$CHUNK_LINE"

echo "Array Task ID ${SLURM_ARRAY_TASK_ID} processing samples: ${SAMPLES[*]}"

# Loop through the assigned 3 samples
for SAMPLE in "${SAMPLES[@]}"; do
    echo "=========================================="
    echo "Starting HUMAnN for sample: ${SAMPLE}"
    echo "=========================================="
    
    INPUT_FASTQ="${CONCAT_DIR}/${SAMPLE}_paired.fastq.gz"
    SAMPLE_OUT="${OUTPUT_DIR}/${SAMPLE}"

    humann \
        --input "$INPUT_FASTQ" \
        --output "$SAMPLE_OUT" \
        --threads "$SLURM_CPUS_PER_TASK"

    echo "Finished sample: ${SAMPLE}"
done
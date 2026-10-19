#!/bin/bash

#SBATCH --job-name=09B_humann_array
#SBATCH --output=09B_humann_%a_o%j
#SBATCH --error=09B_humann_%a_e%j
#SBATCH --time=96:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60G
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

mkdir -p $OUTPUT_DIR

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
    
    INPUT_FASTQ="${CONCAT_DIR}/${SAMPLE}_paired.fastq"
    SAMPLE_OUT="${OUTPUT_DIR}/${SAMPLE}"
    
    # Define expected final output file (HUMAnN names files based on input filename prefix)
    GENEFAMILIES_FILE="${SAMPLE_OUT}/${SAMPLE}_paired_genefamilies.tsv"
    
    # Check if HUMAnN has already successfully run for this sample
    if [ -f "$GENEFAMILIES_FILE" ]; then
        echo "Skipping ${SAMPLE}: Final output file already exists at ${GENEFAMILIES_FILE}"
        continue
    fi

    humann \
        --input "$INPUT_FASTQ" \
        --output "$SAMPLE_OUT" \
        --threads 8 \
        --resume

    echo "Finished sample: ${SAMPLE}"
done

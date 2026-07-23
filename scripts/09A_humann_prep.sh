#!/bin/bash

#SBATCH --job-name=09A_humann_prep
#SBATCH -o 09A_humann_prep_o%j # Standard output
#SBATCH -e 09A_humann_prep_e%j # Standard error
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4GB
#SBATCH --time=24:00:00
#SBATCH --mail-type=END
#SBATCH --mail-user=user@uni.ac.uk


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

# Variable paths

READS_DIR=$src/$parameterD
CONCAT_DIR=$src/cat_files
MANIFEST="sample_chunks.tsv"
CHUNK_SIZE=3

mkdir -p "$CONCAT_DIR"

echo "=== Step 1: Concatenating R1 and R2 Reads ==="
for R1 in "${READS_DIR}"/*$parameterF; do
    [ -e "$R1" ] || { echo "No fastq.gz files found in $READS_DIR"; exit 1; }
    
    BASE=$(basename "$R1" $parameterF)
    R2="${READS_DIR}/${BASE}$parameterR"
    OUT_FASTQ="${CONCAT_DIR}/${BASE}_paired.fastq.gz"

    if [ ! -f "$OUT_FASTQ" ]; then
        echo "Concatenating $BASE..."
        cat "$R1" "$R2" > "$OUT_FASTQ"
    else
        echo "Skipping $BASE (concatenated file exists)"
    fi
done

echo -e "\n=== Step 2: Generating Sample Chunks Manifest ==="
rm -f "$MANIFEST"

# Collect all concatenated samples
SAMPLES=($(ls "${CONCAT_DIR}"/*_paired.fastq.gz | xargs -n1 basename | sed 's/_paired\.fastq\.gz//'))
TOTAL_SAMPLES=${#SAMPLES[@]}

# Group samples into rows of 3
for (( i=0; i<TOTAL_SAMPLES; i+=CHUNK_SIZE )); do
    CHUNK=("${SAMPLES[@]:i:CHUNK_SIZE}")
    # Write tab-separated sample names for each array index
    (IFS=$'\t'; echo "${CHUNK[*]}") >> "$MANIFEST"
done

TOTAL_CHUNKS=$(wc -l < "$MANIFEST" | tr -d ' ')
echo "Done! Processed $TOTAL_SAMPLES samples into $TOTAL_CHUNKS job chunk(s)."
echo "Submit your array job using:"
echo "  sbatch --array=1-${TOTAL_CHUNKS}%10 scripts/09B_humann_array.sh"

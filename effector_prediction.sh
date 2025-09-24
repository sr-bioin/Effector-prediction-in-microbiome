#!/bin/bash
#SBATCH --job-name=protein_phylo
#SBATCH --output=protein_phylo_%j.log
#SBATCH --error=protein_phylo_%j.err
#SBATCH --time=72:00:00
#SBATCH --cpus-per-task=12
#SBATCH --mem=64G
#SBATCH --partition=compute   # change to your cluster partition/queue name

# ================================
# Protein Analysis & Phylogeny Pipeline (SLURM)
# ================================

set -euo pipefail

# Load modules if needed (example below, adjust for your HPC)
# module load signalp/3.0
# module load interproscan/5
# module load orthofinder
# module load prank
# module load raxml
# module load perl

# Input files
PROTEIN_FASTA="/Proteins/sample.fasta"
PROTEIN_FAA="/Proteins/sample.faa"
DNA_FASTA="CLas.fasta"

# Output directories
OUT_DIR="/INTERPROSCAN"
SIGNALP_DIR="$OUT_DIR/Signalp4.1"
PHOBIUS_DIR="$OUT_DIR/Phobius"
TMHMM_DIR="$OUT_DIR/TMHMM"
LIPOP_DIR="./LipoP_out"
ALIGN_DIR="./Alignments"
TREE_DIR="./RAxML"
ORTHO_OUT="./OrthoFinder_out"

mkdir -p "$SIGNALP_DIR" "$PHOBIUS_DIR" "$TMHMM_DIR" "$LIPOP_DIR" "$ALIGN_DIR" "$TREE_DIR" "$ORTHO_OUT"

echo "=== Running SignalP3 ==="
signalp -t gram- -f short -u 0.44 "$PROTEIN_FASTA" > "$SIGNALP_DIR/sample_signP4_OPR.out"

echo "=== Running SignalP4 (InterProScan) ==="
interproscan.sh -f TSV -appl SignalP-GRAM_NEGATIVE \
    -i "$PROTEIN_FASTA" \
    -b "$SIGNALP_DIR/sample.iprscan.signalp_4"

echo "=== Running Phobius (InterProScan) ==="
interproscan.sh -f TSV -appl Phobius \
    -i "$PROTEIN_FASTA" \
    -b "$PHOBIUS_DIR/sample.phobius"

echo "=== Running LipoP ==="
perl LipoP -short -html "$PROTEIN_FAA" > "$LIPOP_DIR/sample_.lipoP"

echo "=== Running deepTMHMM (via InterProScan TMHMM) ==="
interproscan.sh -f TSV -appl TMHMM \
    -i "$PROTEIN_FASTA" \
    -b "$TMHMM_DIR/sample.TMHMM"

echo "=== Orthology clustering with OrthoFinder ==="
orthofinder -f ./Proteins -o "$ORTHO_OUT"

echo "=== Running PRANK alignment ==="
prank -d="$DNA_FASTA" -o="$ALIGN_DIR/CLas_prank.fasta" -DNA -F

echo "=== Concatenating alignments with FASconCAT ==="
perl FASconCAT_v1.1.pl -s -o FcC_smatrix.fasta -p ./Alignments/*.fasta

echo "=== Running RAxML ==="
raxmlHPC-PTHREADS-SSE3 -k -f a -m GTRGAMMA -d \
    -p 12345 -x 12345 \
    -s FcC_smatrix.fasta \
    -n FcC_GAMMA_raxML_N.out \
    -N 1000 -T 12

echo "=== Pipeline Finished Successfully ==="

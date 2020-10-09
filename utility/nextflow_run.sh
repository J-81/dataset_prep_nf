#!/bin/bash

#SBATCH -p nodes
#SBATCH --job-name="nf_wf_manage"
#SBATCH -o slurm_logs/std_output_%j.out
#SBATCH -e slurm_logs/std_error_%j.err
#SBATCH -c 4
#SBATCH --mem=16gb
#SBATCH --time=23:59:59
# #SBATCH --test-only


nextflow pull J-81/dataset_prep_nf
nextflow run J-81/dataset_prep_nf \
  -r dev \
  -profile test \
  -with-tower \
  -resume

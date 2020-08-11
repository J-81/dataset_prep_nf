#!/bin/bash

#SBATCH -p nodes
#SBATCH --job-name="nf_wf_manage"
#SBATCH -o slurm_logs/std_output_%j.out
#SBATCH -e slurm_logs/std_error_%j.err
#SBATCH -c 4
#SBATCH --mem=16gb
#SBATCH --time=23:59:59
#SBATCH -D /home/joribello/nextflow_workflows
# #SBATCH --test-only

export TOWER_ACCESS_TOKEN=7e38ad64660cf92608d67a9425562bc55722d54c
export NXF_VER=20.07.1


./nextflow run main.nf -profile sjsu_slurm -c config/dataset_v1.config -resume -with-tower --limiter 8 -w /gpfs/scratch/joribello/work

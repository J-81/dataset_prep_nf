#!/bin/bash
# Nextflow run using local, but will full resources of one node

#SBATCH -p nodes
#SBATCH --job-name="nf_wf_1Node"
#SBATCH -o std_output_%j.out
#SBATCH -e std_error_%j.err
#SBATCH -c 28
#SBATCH -n 1
#SBATCH -D /home/joribello/nextflow_workflows
# #SBATCH --test-only

export TOWER_ACCESS_TOKEN=7e38ad64660cf92608d67a9425562bc55722d54c
export NXF_VER=20.07.1


./nextflow run test.nf -profile local

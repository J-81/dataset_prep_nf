#! /bin/bash
# Uses rsync to transfer workflow to cloud, does not includes cached results

rsync -aP  --exclude=work \
            --exclude=.git \
            --exclude=*_work \
            --exclude=tmp \
            --exclude=results \
            --exclude=*.log* \
            --exclude=slurm_logs \
            --exclude=*.html* \
            --exclude=*__pycache__* \
            --exclude=bin/IsUnstruct \
            --exclude=utility/pull_transfer_via_rysnc.sh \
            --exclude=config/dataset* \
            --exclude=config/sjsu-slurm.config \
            --exclude=bin/tools/* \
            joribello@spartan01.sjsu.edu:/home/joribello/nextflow_workflows/* .

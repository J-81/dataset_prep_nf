#! /bin/bash
# Uses rsync to transfer workflow to cloud, does not includes cached results

rsync -aP  --exclude=work \
            --exclude=.git \
            --exclude=*_work \
            --exclude=tmp \
            --exclude=results \
            --exclude=*.log* \
            --exclude=*.html* \
            . joribello@spartan01.sjsu.edu:/home/joribello/nextflow_workflows

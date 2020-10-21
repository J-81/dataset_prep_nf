# dataset_prep_nf

Nextflow workflow and associated scripts for preparing protein datasets

Nextflow installation : https://www.nextflow.io/docs/latest/getstarted.html

Uses Nextflow version: 20.07.1

### Additional Setup
- IsUnstruct: http://bioinfo.protres.ru/IsUnstruct/
  - Compile and ensure available in either project bin folder or on PATH
- Blast Database (optional):
  - For local blast, you may download and decompress desired database and ensure location specified in configuration file
  - If not performed, this pipeline will download the required database when performing blast locally.
- Configuration File
  - in folder config, path-related parameters will likely need to be changed

### Recommend Nextflow Environment Variable Setup
- This will cache all workflow conda environments to a single location.  If this is not set, the environment folders will be located in the work directory and not shared between pipelines.
> export NXF_CONDA_CACHEDIR="~/SOME/LOCAL/PATH"

- Set version of Nextflow to use
> export NXF_VER="20.07.1"

- This will allow monitoring the pipeline using website [](tower.nf). While command line output summarizes the pipeline progress as well, tower.nf is much easier to use and can be accessed on any machine with internet access.
  - Follow instructions here: https://tower.nf

### Test Run Instructions
- Uses a limited test set of data, should take about 15 minutes for the first time.
- For the first run, this includes setting up conda environments which may increase runtime by about 10 minutes.
> nextflow run J-81/dataset_prep_nf -profile test


### Production Run Instructions
- A few options are available
1.
> nextflow run J-81/dataset_prep_nf -config {path/to/config} -with-tower

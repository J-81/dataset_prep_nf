# dataset_prep_nf

Nextflow workflow and associated scripts for preparing protein datasets

Nextflow installation : https://www.nextflow.io/docs/latest/getstarted.html

Uses Nextflow version: 20.07.1

### Additional Setup
- IsUnstruct: http://bioinfo.protres.ru/IsUnstruct/
  - Compile and ensure available in either project bin folder or on PATH
- Blast Database: 
  - Download and decompress desired database and ensure location specified in configuration file
- Configuration File
  - in folder config, path-related parameters will likely need to be changed
  - special param: limiter, int, useful for debugging/limited runs

Example Run:
> ./nextflow run main.nf -c config/dataset_v1.config -profile satellite_lite --limiter 300 -resume

Example With Nextflow Tower (Recommended, allows monitoring workflow on website):
1. Obtain Key at : https://tower.nf
2. Export Key as described on the website
> ./nextflow run main.nf -c config/dataset_v1.config -with-tower -profile satellite_lite --limiter 300 -resume

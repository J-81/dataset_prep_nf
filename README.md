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
- Uses a limited test set of data, should take about 20 minutes for the first time.
- About 15 minutes of first run includes setting up conda environments.  If you have set the conda-cache environment, subsequent runs will not require this 15 minute environment setup step.
> nextflow run J-81/dataset_prep_nf -profile test

### Using Your Own Fasta Files
- The header of the file MUST be the following format:
  - \>xxxx_Y
  - where xxxx is the 4 letter PDB ID
  - and Y is the 1 letter Chain ID

### Run Instructions
1. Run using defaults of the pipeline, including generating and using a non-redundant scop fasta sequence set.
> nextflow run J-81/dataset_prep_nf -r main -with-tower

1. Use defaults of the pipeline with a custom input fasta.
> nextflow run J-81/dataset_prep_nf -r main -with-tower --fastaPath {path/to/input/fasta}

1. Run pipeline using custom configuration file.
- Copy the defaults configuration file and modify.
- Location of github: https://github.com/J-81/dataset_prep_nf/raw/main/config/defaults.config
> nextflow run J-81/dataset_prep_nf -r main -config {path/to/newconfig/file} -with-tower

### Other Useful Parameters
Skip subworkflows, useful for preparing specific parts of a dataset only.
- Skip generating IsUnstruct sequence disorder:
> --skipSeqDisorder
- Skip generating secondary structure based switch assignments:
> --skipIsSwitch
- Skip generating blast alignment based sequence entropy:
> --skipSeqEntropy

- Resume a pipeline where it left off.  Useful in cases where an unexpected failure (perhaps internet connection drops causing remote blast to fail) causes the pipeline to fail.
> -resume

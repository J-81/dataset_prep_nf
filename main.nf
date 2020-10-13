#!/usr/bin/env nextflow
/*
========================================================================================
                         J-81/dataset_prep_nf
========================================================================================
 J-81/dataset_prep_nf Dataset Prep Pipeline.
 #### Homepage / Documentation
 https://github.com/J-81/dataset_prep_nf
----------------------------------------------------------------------------------------
*/
nextflow.enable.dsl = 2

// include { STATS_ON_CLUSTERS } from './modules/local/process/analysis.nf'

////////////////////////////////////////////////////
/* --    IMPORT LOCAL MODULES/SUBWORKFLOWS     -- */
////////////////////////////////////////////////////

//include { CAT_FASTQ                   } from './modules/local/process/local/process/cat_fastq'

include { NR_SCOP_FASTA               } from './modules/local/subworkflow/nr_scop_fasta'
include { IS_SWITCH               } from './modules/local/subworkflow/is_switch'

// Subworkflow for obtaining entropy values

// TODO rewire subworkflows, maybe import if allowed
// NF_SETUP: BLAST DATABASE MUST BE DOWNLOADED AND LOCATION SPECIFIED IN DATASET CONFIG
include { BLASTP; PARSE_BLAST; GET_BLAST_DB; ENTROPY } from './modules/local/process/alignments.nf'


workflow entropy {
  take: fasta
  main:
    GET_BLAST_DB | view
    BLASTP( fasta, GET_BLAST_DB.out.blastDB ) | combine( fasta, by:0 ) \
                    | PARSE_BLAST \
                    | ENTROPY

  emit:
    csv = ENTROPY.out


}

// Subworkflow for obtaining disorder propensity

include { ISUNSTRUCT; PARSE_ISUNSTRUCT as PARSE } from './modules/local/process/disorder.nf'

workflow disorder {
  take: fasta
  main:
    ISUNSTRUCT( fasta ) | PARSE

  emit:
    csv = PARSE.out

}

include{ JOIN as JOIN_1; JOIN as JOIN_2; CONCAT; TAG } from './modules/local/process/dataframes.nf'

workflow {
  main:
    NR_SCOP_FASTA | set { fasta }

    fasta | disorder \
          | map { it -> [ it[0], it[1] ] } \
          | set { toJoin }

    fasta | entropy  \
          | map { it -> [ it[0], it[1] ] } \
          | combine( toJoin, by: 0 ) \
          | JOIN_1 \
          | set { toJoin }

    fasta | IS_SWITCH \
          | map { it -> [ it[0], it[2] ] } \
          | combine( toJoin, by: 0 ) \
          | JOIN_2 \
          | set { toConcat }

    // Create column about chain and concatate to one dataset
    toConcat | combine( channel.value( "protein" ) ) \
             | map { it -> [ it[2], it[0], it[1] ] } \
             | TAG \
             | toList \
             | CONCAT



}

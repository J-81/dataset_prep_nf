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
include { SEQ_ENTROPY                 } from './modules/local/subworkflow/seq_entropy'
include { SEQ_DISORDER            } from './modules/local/subworkflow/seq_disorder'

include{ JOIN as JOIN_1; JOIN as JOIN_2; CONCAT; TAG } from './modules/local/process/dataframes.nf'



workflow {
  main:

    // load fasta if supplied, otherwise generate non-redundant scop
    if ( params.fastaPath ) {
    fasta = channel.fromPath( params.fastaPath )
    fasta | view
  } else {
    // generate non-redundant scop
    NR_SCOP_FASTA | set { fasta }
  }

    // split into each id, fastaFile tuples from a multifasta file
    fasta | splitFasta( file: true ) \
          | take( params.limiter ) \
          | map { it -> [ it.splitFasta( record: [id:true] ).id[0].substring(0,6), it ] } \
          | set { fasta_single }

    if ( !params.skipSeqEntropy ) {
    fasta_single | SEQ_ENTROPY  \
                 | map { it -> [ it[0], it[1] ] } \
                 | set { toJoin }
    }

    if ( !params.skipSeqDisorder ) {
    fasta_single | SEQ_DISORDER \
                 | map { it -> [ it[0], it[1] ] } \
                 | combine( toJoin, by: 0 ) \
                 | JOIN_1 \
                 | set { toJoin }
    }

    if ( !params.skipIsSwitch ) {
    fasta_single | IS_SWITCH \
                 | map { it -> [ it[0], it[2] ] } \
                 | combine( toJoin, by: 0 ) \
                 | JOIN_2 \
                 | set { toJoin }
    }

    // nothing left to join, now concatenate all datasets
    toConcat = toJoin
    // Create column about chain and concatate to one dataset
    toConcat | combine( channel.value( "protein" ) ) \
             | map { it -> [ it[2], it[0], it[1] ] } \
             | TAG \
             | toList \
             | CONCAT



}

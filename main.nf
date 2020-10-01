include { GET_PDBSEQRES;  GET_SCOP; EXTRACT_SCOP_PDBIDS; GET_PDB; GET_SSDIS } from './modules/download.nf'
include { CLUSTER2MSA; MAP2MSA } from './modules/cluster.nf'
include { CLUSTER as SCOPCLUSTER; } from './modules/cluster.nf' addParams(min_seq_id: params.scop_min_seq_id)
include { EXTRACT_FASTA as SCOP_EXTRACT_FASTA;
          STRIP_NON_PROTEINS;
          EXTRACT_IDS_FROM_CLUSTERTSV; } from './modules/sequences.nf'
include { OVERLAY_SSDIS;
          SSDIS_TOCSV;
          ISSWITCH } from './modules/isswitch.nf'
include { STATS_ON_CLUSTERS } from './modules/analysis.nf'
include { SSDIS_REFORMAT } from './modules/parser.nf'
// include { STATS_ON_CLUSTERS as PDB_STATS_ON_CLUSTERS} from './modules/analysis.nf'

nextflow.enable.dsl=2

// includes limiter for trials and debugging
workflow scopfasta {
  main:
    GET_PDBSEQRES( params.pdb_seqres_url ) | STRIP_NON_PROTEINS

    GET_SCOP( params.scop_version ) | EXTRACT_SCOP_PDBIDS \
                                    | combine( STRIP_NON_PROTEINS.out ) \
                                    | SCOP_EXTRACT_FASTA

    // The map closure used returns [id, filepath] tuple
    SCOP_EXTRACT_FASTA.out.fasta | SCOPCLUSTER

    SCOPCLUSTER.out.cluster_rep_fasta  | splitFasta( file: true ) \
                                       | take( params.limiter ) \
                                        | map { it -> [ it.splitFasta( record: [id:true] ).id[0] , it ] } \
                                       | set { fasta }


  emit:
    fasta

}

// TODO sanitize fasta by converting non-cannonical amino acids to canonnical equivalents
// TODO add publishdir to final process
workflow isswitch {
  take: fasta
  main:
    GET_PDBSEQRES( params.pdb_seqres_url ) | STRIP_NON_PROTEINS

    MAP2MSA( fasta, STRIP_NON_PROTEINS.out )

    GET_SSDIS | SSDIS_REFORMAT

    OVERLAY_SSDIS( MAP2MSA.out.msa , SSDIS_REFORMAT.out ) | SSDIS_TOCSV

    MAP2MSA.out.msa | combine( SSDIS_TOCSV.out, by:0 ) \
                    | ISSWITCH

                    /* \
                    | map { it[2] } \
                    | collect \
                    | AGGREGATE_ISSWITCH
                    */

    emit:
      csv = ISSWITCH.out.full

}


// Subworkflow for obtaining entropy values

// TODO rewire subworkflows, maybe import if allowed
// NF_SETUP: BLAST DATABASE MUST BE DOWNLOADED AND LOCATION SPECIFIED IN DATASET CONFIG
include { BLASTP; PARSE_BLAST; GET_BLAST_DB; ENTROPY } from './modules/alignments.nf'


workflow entropy {
  take: fasta
  main:
    BLASTP( fasta, GET_BLAST_DB.out.blastDB ) | combine( fasta, by:0 ) \
                    | PARSE_BLAST \
                    | ENTROPY

  emit:
    csv = ENTROPY.out


}

// Subworkflow for obtaining disorder propensity

include { ISUNSTRUCT; PARSE_ISUNSTRUCT as PARSE } from './modules/disorder.nf'

workflow disorder {
  take: fasta
  main:
    ISUNSTRUCT( fasta ) | PARSE

  emit:
    csv = PARSE.out

}

include{ JOIN as JOIN_1; JOIN as JOIN_2; CONCAT; TAG } from './modules/dataframes.nf'

workflow {
  main:
    scopfasta | set { fasta }

    fasta | disorder \
          | map { it -> [ it[0], it[1] ] } \
          | set { toJoin }

    fasta | entropy  \
          | map { it -> [ it[0], it[1] ] } \
          | combine( toJoin, by: 0 ) \
          | JOIN_1 \
          | set { toJoin }

    fasta | isswitch \
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

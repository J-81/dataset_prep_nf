nextflow.enable.dsl=2

include { GET_PDBSEQRES; GET_SCOP; EXTRACT_SCOP_PDBIDS } from '../process/download.nf'
include { CLUSTER } from '../process/cluster.nf' addParams(min_seq_id: params.scop_min_seq_id)
include { EXTRACT_FASTA; STRIP_NON_PROTEINS; EXTRACT_IDS_FROM_CLUSTERTSV; } from '../process/sequences.nf'


// includes limiter for trials and debugging
workflow NR_SCOP_FASTA {
  main:
    GET_PDBSEQRES( params.pdb_seqres_url ) | STRIP_NON_PROTEINS

    GET_SCOP( params.scop_version ) | EXTRACT_SCOP_PDBIDS \
                                    | combine( STRIP_NON_PROTEINS.out ) \
                                    | EXTRACT_FASTA

    // The map closure used returns [id, filepath] tuple
    EXTRACT_FASTA.out.fasta | CLUSTER

    CLUSTER.out.cluster_rep_fasta  | splitFasta( file: true ) \
                                   | take( params.limiter ) \
                                   | map { it -> [ it.splitFasta( record: [id:true] ).id[0] , it ] } \
                                   | set { fasta }

  emit:
    fasta

}

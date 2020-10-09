include { GET_PDBSEQRES; GET_SCOP; EXTRACT_SCOP_PDBIDS } from '../modules/download.nf'
include { CLUSTER } from '../modules/cluster.nf' addParams(min_seq_id: params.scop_min_seq_id)
include { EXTRACT_FASTA; STRIP_NON_PROTEINS; EXTRACT_IDS_FROM_CLUSTERTSV; } from '../modules/sequences.nf'


// includes limiter for trials and debugging
workflow scopFasta {
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

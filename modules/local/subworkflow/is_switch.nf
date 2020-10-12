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

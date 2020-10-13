nextflow.enable.dsl=2

include { GET_PDBSEQRES;  GET_SSDIS } from '../process/download.nf'
include { OVERLAY_SSDIS;
          SSDIS_TOCSV;
          ISSWITCH } from '../process/isswitch.nf'
include { SSDIS_REFORMAT } from '../process/parser.nf'


// TODO sanitize fasta by converting non-cannonical amino acids to canonnical equivalents
// TODO add publishdir to final process
workflow IS_SWITCH {
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

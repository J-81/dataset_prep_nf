nextflow.enable.dsl=2


// Subworkflow for obtaining entropy values

// TODO rewire subworkflows, maybe import if allowed
include { BLASTP; PARSE_BLAST; GET_BLAST_DB; ENTROPY } from '../process/alignments.nf'


workflow SEQ_ENTROPY {
  take: fasta
  main:
    GET_BLAST_DB | view
    BLASTP( fasta, GET_BLAST_DB.out.blastDB ) | combine( fasta, by:0 ) \
                    | PARSE_BLAST \
                    | ENTROPY

  emit:
    csv = ENTROPY.out


}

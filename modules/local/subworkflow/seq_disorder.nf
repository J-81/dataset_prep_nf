// Subworkflow for obtaining disorder propensity

include { ISUNSTRUCT; PARSE_ISUNSTRUCT as PARSE } from '../process/disorder.nf'

workflow SEQ_DISORDER {
  take: fasta
  main:
    ISUNSTRUCT( fasta ) | PARSE

  emit:
    csv = PARSE.out

}

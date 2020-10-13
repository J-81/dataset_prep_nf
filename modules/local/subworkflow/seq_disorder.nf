// Subworkflow for obtaining disorder propensity

include { ISUNSTRUCT; PARSE_ISUNSTRUCT as PARSE } from '../process/disorder.nf'

workflow disorder {
  take: fasta
  main:
    ISUNSTRUCT( fasta ) | PARSE

  emit:
    csv = PARSE.out

}

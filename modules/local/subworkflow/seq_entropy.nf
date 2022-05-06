nextflow.enable.dsl=2


// Subworkflow for obtaining entropy values

// TODO rewire subworkflows, maybe import if allowed
include { BLASTP; PARSE_BLAST; GET_BLAST_DB; ENTROPY } from '../process/alignments.nf'


workflow SEQ_ENTROPY {
  take: fasta
  main:
    if ( params.blastLocal ) {
    GET_BLAST_DB()
    GET_BLAST_DB.out.blastDB | set { ch_blast_db }
    BLASTP( fasta, ch_blast_db ) | set { ch_blast_xml }
  } else {
    // dummy file to satisfy uneeded blast database input
    BLASTP( fasta, file("dummy") ) | set { ch_blast_xml }
  }
     // parse xml file and compute entropy
     ch_blast_xml  | combine( fasta, by:0 ) \
                   | PARSE_BLAST \
                   | ENTROPY \
                   | view { id, out_file -> """\
                             Storing entropy table for '${id}'
                               file ${out_file} in 'EntropyTables'
                             """.stripIndent()}

  emit:
    csv = ENTROPY.out


}

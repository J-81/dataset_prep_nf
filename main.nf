include { GET_PDBSEQRES;  GET_SCOP; EXTRACT_SCOP_PDBIDS } from './modules/download.nf'
include { CLUSTER; CLUSTER2MSA } from './modules/cluster.nf'
include { EXTRACT_FASTA; STRIP_NON_PROTEINS; } from './modules/sequences.nf'


nextflow.enable.dsl=2

//params.outdir = "results"
workflow {
	// data = Channel.fromPath(params.pdb_seqres_url)
	CLUSTER( STRIP_NON_PROTEINS( GET_PDBSEQRES( params.pdb_seqres_url ) ) )
  CLUSTER.out.cluster_ids.view()

  EXTRACT_SCOP_PDBIDS( GET_SCOP( 2.05))
	EXTRACT_FASTA( EXTRACT_SCOP_PDBIDS.out, STRIP_NON_PROTEINS.out )

	CLUSTER2MSA( EXTRACT_FASTA.out.fasta, STRIP_NON_PROTEINS.out )


}

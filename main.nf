include { GET_PDBSEQRES;  GET_SCOP; EXTRACT_SCOP_PDBIDS; GET_DSSP } from './modules/download.nf'
include { CLUSTER2MSA; MAP2MSA } from './modules/cluster.nf'
include { CLUSTER as SCOPCLUSTER; } from './modules/cluster.nf' addParams(min_seq_id: params.scop_min_seq_id)
include { EXTRACT_FASTA as SCOP_EXTRACT_FASTA; STRIP_NON_PROTEINS; EXTRACT_IDS_FROM_CLUSTERTSV } from './modules/sequences.nf'
include { STATS_ON_CLUSTERS as SCOP_STATS_ON_CLUSTERS} from './modules/analysis.nf'
// include { STATS_ON_CLUSTERS as PDB_STATS_ON_CLUSTERS} from './modules/analysis.nf'

nextflow.enable.dsl=2

//params.outdir = "results"
workflow {
	// data = Channel.fromPath(params.pdb_seqres_url)
	// PDBCLUSTER( STRIP_NON_PROTEINS( GET_PDBSEQRES( params.pdb_seqres_url ) ) )
	GET_PDBSEQRES( params.pdb_seqres_url ) | STRIP_NON_PROTEINS
  // PDBCLUSTER.out.cluster_ids.view()

  EXTRACT_SCOP_PDBIDS( GET_SCOP( params.scop_version ))
	SCOP_EXTRACT_FASTA( EXTRACT_SCOP_PDBIDS.out, STRIP_NON_PROTEINS.out )

	SCOPCLUSTER( SCOP_EXTRACT_FASTA.out.fasta )

	CLUSTER2MSA(  SCOPCLUSTER.out.cluster_rep_fasta | splitFasta( file:true) | take ( params.limiter ),
								STRIP_NON_PROTEINS.out )

	MAP2MSA(  SCOPCLUSTER.out.cluster_rep_fasta | splitFasta( file:true) | take ( params.limiter ),
								STRIP_NON_PROTEINS.out )

								/* WIP
								SCOPCLUSTER.out.cluster_rep_fasta \
														| splitFasta( file:true) \
													  | take ( params.limiter ) \
														| combine ( STRIP_NON_PROTEINS.out ) \
														| (CLUSTER2MSA & MAP2MSA) \
														| view */


	SCOP_STATS_ON_CLUSTERS( SCOPCLUSTER.out.cluster_ids )

	//EXTRACT_IDS_FROM_CLUSTERTSV( CLUSTER2MSA.out.cluster_ids )

	//CLUSTER2MSA.out.msa | view

	// EXTRACT_IDS_FROM_CLUSTERTSV.out | splitText { it.trim() } | unique | GET_DSSP
}

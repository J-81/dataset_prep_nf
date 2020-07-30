process GET_PDBSEQRES {

	input:
	  path x

	output:
	  path 'out.ent'

	script:
	"""
	gunzip -c $x > out.ent
	"""

}

process GET_SCOP {
	input:
		val scop_version
	output:
	  path 'scopFile.txt'
	script:
	  scope_versions = [2.07, 2.06, 2.05, 2.04, 2.03, 2.02, 2.01] // new scope versions
		scop_versions = [1.75, 1.73, 1.71, 1.69, 1.67, 1.65, 1.63, 1.61, 1.59, 1.57, 1.55] // older scop versions
		if( scope_versions.contains(scop_version) )
	        """
	        wget -O scopFile.txt \
					https://scop.berkeley.edu/downloads/parse/dir.des.scope.${scop_version}-stable.txt
	        """

	    else if( scop_versions.contains(scop_version) )
	        """
					wget -O scopFile.txt \
					https://scop.berkeley.edu/downloads/parse/dir.des.scop.${scop_version}.txt
	        """
			else
					error "Scop version not found: ${scop_version}, see https://scop.berkeley.edu/downloads"
}

process EXTRACT_SCOP_PDBIDS {
	conda 'envs/biopython.yml'
	input:
		path x
	output:
	  path "scopIDs.json"
	script:
	  """
		extract_scop_PDBIDs.py $x scopIDs.json
		"""
}

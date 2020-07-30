// Processes related to manipulating fasta file based on id lookups

// TODO consider making the idsJson into a val
process EXTRACT_FASTA {
  conda 'envs/biopython.yml'
  input:
    path idsJson
    path dbFasta
  output:
    path 'out.fasta', emit: fasta
    path 'missing.txt', emit: missing_records
  script:
    """
    extract_fasta.py $idsJson $dbFasta out.fasta missing.txt
    """
}

process STRIP_NON_PROTEINS {
	conda "envs/biopython.yml"
	input:
	  path fasta
	output:
		path 'proteins.fasta'
	script:
		"""
		strip_non_proteins.py $fasta proteins.fasta
		"""
}

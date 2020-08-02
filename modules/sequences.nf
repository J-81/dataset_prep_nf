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

process EXTRACT_IDS_FROM_CLUSTERTSV {
  // Get pdb 4 IDs using cluster TSV
  echo false

  input:
    path inputTSV
  output:
    path 'ids.txt'
  script:
    """
    awk '{print substr(\$2,1,4) }' $inputTSV > ids.txt
    """


}

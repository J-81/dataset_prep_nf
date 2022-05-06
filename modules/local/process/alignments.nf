process GET_BLAST_DB {
  conda "${baseDir}/envs/blast.yml"
  storeDir "${params.blastdbStoreDir}"

  output:
    path "${params.blastdb}", emit: blastDB
    path "README.md", emit: readmeBlastDB

  script:
    """
    mkdir ${params.blastdb}
    cd ${params.blastdb}
    update_blastdb.pl --source ncbi \\
      --decompress \\
      --blastdb_version 5 \\
      ${params.blastdb}

    # back to root work dir
    cd -

    echo "Download Date: \$(date)" >> README.md
    """
}

process BLASTP {
  conda "${baseDir}/envs/blast.yml"
  label 'time_limit_2h','longer'
  // if using remote blast, limit to 2 at a time to be
  //   a responsible NCBI shared resource user!
  if ( !params.blastLocal ) { maxForks = 2 }

  input:
    tuple val(fastaID), path(inputFasta)
    path(blastDB) // when using remote blast, a dummy file should be supplied
  output:
    tuple val(fastaID), path("${fastaID}_hits.xml"), emit: hitsXML
  script:
    if ( params.blastLocal ) {
      """
      blastp -query $inputFasta \\
        -db $blastDB/${params.blastdb} \\
        -max_target_seqs 1000 \\
        -num_threads $task.cpus \\
        -outfmt 5 \\
        -out ${fastaID}_hits.xml
      """
    } else {
      """
      blastp -query $inputFasta \\
        -db ${params.blastdb} \\
        -remote \\
        -max_target_seqs 1000 \\
        -outfmt 5 \\
        -out ${fastaID}_hits.xml
      """
    }
}

process PARSE_BLAST {
  conda "${baseDir}/envs/biopython_pandas.yml"


  input:
    tuple val(fastaID), path(inputXML), path(fasta)
  output:
    tuple val(fastaID), path("${fastaID}.csv")
  script:
    """
    extract_aligned_by_position.py $inputXML $fasta  ${fastaID}.csv $params.blast_score_cut_off $params.blast_homolog_min
    """
}

/* Calculates entropy with table of strings
 *  - Uses categorical classes based on [1] S. Scholarworks and R. Nepal, “Application of Query-Based Qualitative Descriptors in Conjunction with Protein Sequence Homology for Prediction of Residue Solvent Accessibility Recommended Citation Nepal, Reecha, &quot;Application of Query-Based Qualitative Descriptors in Conjunction wi,” Master’s Theses, Jan. 2013, doi: 10.31979/etd.em6c-qn2b.
 */

process ENTROPY {
  publishDir "EntropyTables"
  conda "${baseDir}/envs/scipy1.yml"

  input:
    tuple val(fastaID), path(inputCSV)
  output:
    tuple val(fastaID), path("${fastaID}_entropy.csv")
  script:
    """
    entropy.py $inputCSV $params.entropy_log_base ${fastaID}_entropy.csv
    """
}

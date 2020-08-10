process CLUSTER {
  conda "envs/mmseqs2.yml"
  input:
    path inputFasta
  output:
    path "cluster_all_seqs.fasta", emit: cluster_fasta
    path "cluster_cluster.tsv", emit: cluster_ids
    path "cluster_rep_seq.fasta", emit: cluster_rep_fasta
  script:
    """
    mmseqs easy-cluster $inputFasta cluster tmp --min-seq-id ${params.min_seq_id}

    # cleanup to reduce file storage needs
    rm -r tmp/*
    """
}

process STATS_ON_CLUSTERS {
  input:
    path cluster_ids
  output:
    path "logs/cluster_stats.txt"
  script:
    """
    echo NOT DONE
    """
}


// BUG: minor impact, trailing X in original sequence seems to dissapear in aligment, X's elsewhere appear as indels '-'
process CLUSTER2MSA {
  conda 'envs/mmseqs2.yml'
  echo false
  label 'big_job'

  input:
    path queryFasta
    path searchFasta
  output:
    path 'clusters.aln', emit: msa
    path 'clusters.tsv', emit: cluster_ids
  script:
    """
    mmseqs createdb $searchFasta targetDB
    mmseqs createdb $queryFasta queryDB
    mmseqs search queryDB targetDB alignDB tmp \\
      --min-seq-id $params.min_seq_id \\
      --max-seqs 999999 \\
      --slice-search
    mmseqs result2msa queryDB targetDB alignDB clusters.aln \\
      --skip-query
    mmseqs createtsv queryDB targetDB alignDB clusters.tsv --first-seq-as-repr
    """
}


process MAP2MSA {
  errorStrategy 'ignore' //for debugging
  conda 'envs/mmseqs2.yml'
  echo false
  // label 'big_job' associated speed up is not worth, compared to parallelization

  input:
    tuple val(repID), path(queryFasta)
    path searchFasta
  output:
    tuple val(repID), path("${repID}_cluster.aln"), emit: msa
    tuple val(repID), path("${repID}_cluster.tsv"), emit: tsv
  script:
    """
    mmseqs createdb $searchFasta targetDB
    mmseqs createdb $queryFasta queryDB
    mmseqs map queryDB targetDB alignDB tmp \\
      --min-seq-id $params.min_seq_id \\
      --max-seqs 999999 \\
      -c $params.coverage \\
      -a
    mmseqs result2msa queryDB targetDB alignDB preclusters.aln \\
      --skip-query
    mmseqs createtsv queryDB targetDB alignDB ${repID}_cluster.tsv --first-seq-as-repr

    # REMOVE UNECESSARY ESCAPE CHARACTER AT END, THIS WOULD CAUSE ISSUES IN BIOPYTHON PARSING
    tr -cd '\11\12\15\40-\176' < preclusters.aln > ${repID}_cluster.aln

    # remove files, saves space in long run
    rm -r targetDB* queryDB* alignDB* tmp*
    """
}
//
// Splits the alignment file output by mmseqs into indivudual alignment files
//
/*
process SPLIT_CLUSTERS {
  input:
    path mmseqsAln
  output:
    path "*.fasta", emit: clusters
  script:
    """
    split

}
*/

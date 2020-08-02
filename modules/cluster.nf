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
    mmseqs map queryDB targetDB alignDB tmp \\
      --min-seq-id $params.min_seq_id \\
      --max-seqs 999999 \\
      -c $params.coverage \\
      -a
    mmseqs result2msa queryDB targetDB alignDB clusters.aln \\
      --skip-query
    mmseqs createtsv queryDB targetDB alignDB clusters.tsv --first-seq-as-repr
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

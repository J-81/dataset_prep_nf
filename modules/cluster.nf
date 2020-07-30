process CLUSTER {
  conda "envs/mmseqs2.yml"
  input:
    path inputFasta
  output:
    path "cluster_all_seqs.fasta", emit: cluster_fasta
    path "cluster_cluster.tsv", emit: cluster_ids
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

  input:
    path queryFasta
    path searchFasta
  output:
    path 'msa.aln', emit: msa
    path 'clusters.tsv', emit: cluster_ids
  script:
    """
    mmseqs createdb $searchFasta targetDB
    mmseqs createdb $queryFasta queryDB
    mmseqs search queryDB targetDB alignDB tmp \\
      --min-seq-id $params.min_seq_id \\
      --max-seqs 999999 \\
      --slice-search
    mmseqs result2msa queryDB targetDB alignDB msa.aln \\
      --skip-query \\ Needed as the scop fasta to prevent duplicate entries in MSA
    mmseqs createtsv queryDB targetDB alignDB cluster.tsv --first-seq-as-repr
    """
}

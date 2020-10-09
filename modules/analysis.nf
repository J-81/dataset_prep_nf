process STATS_ON_CLUSTERS {
  conda "${baseDir}/envs/data-viz.yml"
  input:
    path clusterTSV
  output:
    path "Cluster-Member-Sizes.png"
    path "Cluster-Member-Sizes-exclude-singletons.png"
    path "interactive.html"
  script:
    """
    stats_on_clusters.py $clusterTSV
    """
}

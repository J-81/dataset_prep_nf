nextflow.enable.dsl=2

process echo2s {
  input:
    val x
  output:
    path "${x}_done.txt"
  script:
    """
    sleep 20
    touch ${x}_done.txt
    """
}

process bigJob {
  label 'big_job'

  input:
    val x
  output:
    path "${x}_bigdone.txt"
  script:
    """
    sleep 20
    touch ${x}_bigdone.txt
    """
}

nums = Channel.of( 1, 2, 3, 4, 5 )
nums2 = Channel.of( 6, 7, 8, 9, 10 )

workflow {
  nums | echo2s
  nums2 | bigJob
}

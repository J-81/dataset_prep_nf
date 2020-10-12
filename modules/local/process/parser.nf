process SSDIS_REFORMAT {
  conda "${baseDir}/envs/biopython.yml"
  label "big_job"

  input:
  path ss_dis
  output:
  path "ss_dis.json"
  script:
  """
  ss_dis_reformat.py $ss_dis
  """

}

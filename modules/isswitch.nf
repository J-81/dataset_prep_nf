process AGGREGATE_ISSWITCH {
  conda "envs/biopython_pandas.yml"

  input:
  path collectionOfCSV
  output:
  path "final.csv"
  script:
  """
  mkdir toConcat
  mv $collectionOfCSV toConcat/
  aggregate_results.py toConcat final.csv
  """
}

process OVERLAY_SSDIS {
  conda "envs/biopython.yml"

  input:
  tuple val(repID), path(inputMSA)
  path ssdisJSON
  output:
  tuple val(repID), path("${inputMSA}.ss"), emit: msa
  script:
  """
  overlay_ssdis.py $ssdisJSON $inputMSA ${inputMSA}.ss
  """

}

process SSDIS_TOCSV {
  conda "envs/biopython.yml"

  input:
  tuple val(repID), path(ssdisMSA)
  output:
  tuple val(repID), path("${ssdisMSA}.csv"), emit: msa
  script:
  """
  ssdis_tocsv.py $ssdisMSA ${ssdisMSA}.csv
  """
}

process ISSWITCH {
  conda "envs/biopython_pandas.yml"

  input:
  tuple val(repID), path(inputMSA), path(inputCSV) //inputMSA is primary alignment
  output:
  tuple val(repID), path("${repID}_full.csv"), path("${repID}.csv"),  emit: full
  script:
  """
  assess_isSwitch.py $inputMSA $inputCSV ${repID}_full.csv $repID
  """

}

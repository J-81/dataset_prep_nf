// Processes for handling dataframes

process JOIN {
  conda "${baseDir}/envs/biopython_pandas.yml"

  input:
    tuple val(fastaID), path(csv1), path(csv2)
  output:
    tuple val(fastaID), path("${fastaID}_dataset_plus_${csv2.getSimpleName()}.csv")
  script:
    """
    join.py $csv1 $csv2 ${fastaID}_dataset_plus_${csv2.getSimpleName()}.csv
    """

}

/*
 * Concatenate dataframes row-wise
 */

 process CONCAT {
   conda "${baseDir}/envs/biopython_pandas.yml"
   publishDir "${params.publishdir}", mode: 'copy', overwrite: false

   input:
    path collectionOfCSV
   output:
    path "final.csv"
   script:
     """
     aggregate_results.py . final.csv
     """
 }

/*
 * Creates a column based on input value,
 * e.g. Used for protein chain
 */
process TAG {
  conda "${baseDir}/envs/biopython_pandas.yml"

  input:
    tuple val(col_name), val(col_content), path(i_csv)
  output:
    path("tagged_${i_csv}")
  script:
    """
    #! /usr/bin/env python

    import pandas as pd

    df = pd.read_csv("${i_csv}", index_col=0)
    df["${col_name}"] = "${col_content}"
    df.to_csv("tagged_${i_csv}")
    """
}

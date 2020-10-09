/*
 *  Processes related to sequence disorder
 */

/*
 * Uses Isunstruct availabe here: http://bioinfo.protres.ru/IsUnstruct/
 * NF_SETUP: Install isunstruct, link binary to project bin or ensure in PATH
 */

process ISUNSTRUCT {
  input:
    tuple val(fastaID), path(inputFasta)
  output:
    tuple val(fastaID), path("${fastaID}.iul")
  script:
    """
    # ensure naming as IsUnstruct does not allow output naming
    mv $inputFasta ${fastaID}.fasta

    IsUnstruct ${fastaID}.fasta

    # save space and remove unused output file
    rm ${fastaID}.ius
    """
}

/*
 * Parses results to CSV
 */

process PARSE_ISUNSTRUCT {
  conda "${baseDir}/envs/biopython_pandas.yml" // TODO: create only pandas environment 

  input:
    tuple val(fastaID), path(inputIUL)
  output:
    tuple val(fastaID), path("${fastaID}.csv")
  script:
    """
    parse_isunstruct.py $inputIUL ${fastaID}.csv
    """

}

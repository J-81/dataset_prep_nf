process GET_NR_DB {
  conda 'envs/blast.yml'
  storeDir 'db/blast'

  output:
    path "tmp/", emit: blastdbDir // update after running this command

  script:
    """
    mkdir tmp
    cd tmp
    update_blastdb.pl --source ncbi --decompress --blastdb_version 5 nr
    """
}

process BLASTP {
  conda 'envs/blast.yml'
  label 'big_job'

  input:
    path inputFasta
    path blastdbDir
  output:
    path 'hits.xml', emit: hitsXML
  script:
    """
    blastp -query $inputFasta -db $blastdbDir -max_target_seqs 10000 -num_threads 8 -outfmt 5 -out hits.xml
    """
}

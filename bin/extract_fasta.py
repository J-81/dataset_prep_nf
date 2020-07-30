#! /usr/bin/env python
import sys
import json

from Bio import SeqIO


ids = sys.argv[1] # ids to extract from dbFasta
dbFasta = sys.argv[2] # usually pdb_seqres or a derived fasta
outFasta = 'out.fasta' # write extracted records to this file
missingTxt = 'missing.txt' # record all ids not found in dbFasta



missing = list()
with open(ids, 'r') as f:
    idSet = set(json.load(f))

with open(outFasta, "w") as f:
    for record in SeqIO.parse(dbFasta, "fasta"):
        if record.id in idSet:
            SeqIO.write(record, f, "fasta")
            idSet.remove(record.id) # keep track of what has not been found

with open(missingTxt, "w") as f:
    json.dump(list(idSet), f) # convert to list, sets cannot be json dumped

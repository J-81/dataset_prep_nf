#! /usr/bin/env python
# Author: Jonathan Oribello
import sys


from Bio import SeqIO

# input
#inPath = "work/71/7a35f053991023073a5e6c999e22d7/pdb_seqres.txt"
inPath = sys.argv[1]
# output Path
#outPath = "tmp/out.test"
outPath = sys.argv[2]

with open(outPath, "w") as f_out:
    with open(inPath, "r") as f_in:
        for record in SeqIO.parse(f_in, "fasta"):
            _, moleculeType, *_ = record.description.split()
            if  moleculeType == "mol:protein":
                SeqIO.write(record, f_out, format="fasta")

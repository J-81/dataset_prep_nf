#! /usr/bin/env python
import csv
import sys

from Bio import SeqIO


i_msa = sys.argv[1]
o_csv = sys.argv[2]


def convert_msa_to_csv(msa, _csv):
    with open(msa, "r") as f:
        seqs = [seq for seq in SeqIO.parse(msa, format="fasta")]

    # iterate through first seq (all will be same length) and populate a by position dictionary
    seq_ids = ",".join([seq.id for seq in seqs])
    #print(seq_ids)
    by_position = [''.join(position) for position in zip(*[seq.seq for seq in seqs])]
    #print(by_position)
    with open(_csv, "w") as f:

        # write sequence ids as header
        f.write(seq_ids+"\n")

        # write characters
        csv_writer = csv.writer(f)
        csv_writer.writerows(by_position)


convert_msa_to_csv(msa=i_msa, _csv=o_csv)

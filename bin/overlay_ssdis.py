#! /usr/bin/env python
import json
import sys

from Bio import SeqIO, AlignIO, Seq


#i_ssdis = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/cc/be6daff4e27d07a214a4fa1902b60f/ss_dis.txt"
i_ssdis = sys.argv[1]
i_msa = sys.argv[2]
o_msa = sys.argv[3]

def _fetch_ssdis_info(aligned_seq, ssdis):
    """ parses ID, assumes xxxx_X format where upper and lowercases are as shown """
    _id = f"{aligned_seq.id[0:4].upper()}{aligned_seq.id[5].upper()}"
    try:
        unaligned_ssdis = ssdis[_id]
    except KeyError:
        #print(f"MISSING {_id}") ## DEBUG
        return '_', "?"*len(aligned_seq) # this is handled during convert_to_secsctruct_alignment to prevent indel reinsertion
    return unaligned_ssdis

def _insert_indels(unaligned_secondary, indel_indices):
    unaligned_secondary = list(unaligned_secondary)
    for indel_loc in indel_indices:
        unaligned_secondary.insert(indel_loc, "-")
    aligned_secondary = "".join(unaligned_secondary)
    return aligned_secondary


def covert_to_secstruct_alignment(primary_msa, output_msa, ss_dis):
    finished_seqs = list()
    print(primary_msa)
    for aligned_seq in AlignIO.read(primary_msa, format="fasta"):
        # find where indel are located in aligned_sequence
        indel_indices = [i for i,v in enumerate(aligned_seq) if v == "-"]

        # get unaligned_secondary sequence
        _, unaligned_secondary = _fetch_ssdis_info(aligned_seq, ss_dis)

        # insert indel into unaligned secondary sequence to create aligned sequence
        if "?" in unaligned_secondary:
            #raise ValueError(f"Missing SSDIS: {primary_msa}")
            #print(f"Missing {aligned_seq.id} in {i_ssdis}")
            aligned_secondary = unaligned_secondary
        else:
            aligned_secondary = _insert_indels(unaligned_secondary, indel_indices)

        # replace primary with secondary sequence
        aligned_seq.seq = Seq.Seq(aligned_secondary)

        finished_seqs.append(aligned_seq)

    # write to file
    with open(output_msa, "w") as f:
        SeqIO.write(finished_seqs, handle=f, format="fasta")


### Load ssdis once # actually pretty fast json load
with open(i_ssdis, "r") as f:
    ssdis = json.load(f)


covert_to_secstruct_alignment(primary_msa=i_msa,
                              output_msa=o_msa,
                              ss_dis=ssdis)

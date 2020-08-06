#! /usr/bin/env python
# calculate entropy
# based on [1] S. Scholarworks and R. Nepal, “Application of Query-Based Qualitative Descriptors in Conjunction with Protein Sequence Homology for Prediction of Residue Solvent Accessibility Recommended Citation Nepal, Reecha, &quot;Application of Query-Based Qualitative Descriptors in Conjunction wi,” Master’s Theses, Jan. 2013, doi: 10.31979/etd.em6c-qn2b.


import sys

from Bio.Blast import NCBIXML
from Bio import SeqIO
import pandas as pd


i_xml = sys.argv[1]
#i_xml = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/b1/48f73e7d1f44d87797b0c7bca4ac0e/1o50_A_hits.xml"
i_fasta = sys.argv[2]
#i_fasta = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/8f/917b8f8bd2815803caec837679431f/cluster_rep_seq.1.fasta"
o_csv = sys.argv[3]
#o_csv = "tmp/test.csv"

# parameters
SCORE_CUT_OFF_PERCENT = float(sys.argv[4])
#SCORE_CUT_OFF_PERCENT = 40
HOMOLOG_MIN = int(sys.argv[5])
#HOMOLOG_MIN = 1



with open(i_xml, "r") as f:
     # while this can handle multiple queries
     # we will only assume only one query used in blastp for this process script
    for query in NCBIXML.parse(handle=f):
        query = query
        continue

# initate position dict, first letter in query is 1 as per blast indexing
byPositionDict = dict()
for i in range(1,query.query_length+1):
    byPositionDict[i] = ""

# track total alignments used
total_alignments = 0
# iterate through all alignments
for index_aln, aln in enumerate(query.alignments):
    # iterate through all hsps in alignment
    for index_hsp, hsp in enumerate(aln.hsps):

        # set score minimum based on first alignment bit score
        if all([index_aln == 0, index_hsp == 0]):
            scoreMin = hsp.bits * SCORE_CUT_OFF_PERCENT / 100.0

        # skip hsp falling under the minimum score
        if hsp.bits < scoreMin:
            continue
        else:
            total_alignments += 1

            # not needed
            # add leading unaligned regions, 1 to query_start (end non-inclusive)
            #for i in range(1,hsp.query_start):
            #    byPositionDict[i] += '_'

            # add matching region subject letters
            gapCount = 0
            for i, letter in enumerate(hsp.sbjct):
                # track gaps in query
                if hsp.query[i] == "-":
                    gapCount += 1
                    #continue
                Pos = i + hsp.query_start - gapCount
                #print(letter, Pos, hsp.query[i])
                byPositionDict[Pos] += letter

# fail condition
if total_alignments < HOMOLOG_MIN:
    raise ValueError(f"{total_alignments} found.  Under minimum {HOMOLOG_MIN}.  Failing Calculation")

# convert to dataframe
df = pd.DataFrame(data=byPositionDict.values(),
                  index=pd.Index(data=byPositionDict.keys(), name="query_index"),
                  columns=["alignments"])

# append primary sequence of query
fasta = SeqIO.read(i_fasta, "fasta")
df["Residue"] = fasta.seq

# save dataframe
df.to_csv(o_csv)

#! /usr/bin/env python
from functools import partial
import math
import sys

import pandas as pd
from scipy.stats import entropy


from lib_entropy.AminoAcidClasses import E6, E20
#from bin.lib_entropy.AminoAcidClasses import E6, E20

################################################################################
# Input/Output and parameters set
################################################################################
i_csv = sys.argv[1]
#i_csv = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/8a/f227932e0adadd501f906e6a7fa34d/1o51_A.csv"

# logic here allows "e"
LOG_BASE = sys.argv[2]
if LOG_BASE == "e":
    LOG_BASE = math.e
else:
    LOG_BASE = float(LOG_BASE)

o_csv = sys.argv[3]

################################################################################
# Define necessary functions
################################################################################
def _map_to_classes(seq: str, encodeMap: dict, gaps: str = 'keep') -> str:
    """ Remap characters in a sequence to classes

    Used for entropy amino acid classes

    params:
        gaps: one of 'remove', 'keep', 'convert'

    Raises KeyError if character has no mapping defined
    """
    # float "Nan" refers to cases with no alignments at the position
    if isinstance(seq, float):
        return seq
    else:
        newSeq = str()
        chars = list(seq)
        for char in chars:
            # deal with gap characters
            if char == "-":
                # remove gaps by default
                if gaps == 'remove':
                    continue
                elif gaps == 'keep':
                    newSeq += char
                # requires encoding defined for gap character
                elif gaps == 'convert':
                    newSeq += encodeMap[char]
                else:
                    raise ValueError(f"gaps argument option {gaps} not implemented")

            else:
                newSeq += encodeMap[char]

    return newSeq


def _entropy(seq):
    """ wrapper around scipy shannon entropy function

    passes Nan back if encountered

    """
    # float "Nan" refers to cases with no alignments at the position
    if isinstance(seq, float):
        return seq
    else:
        seq = pd.Series(list(seq))
        seq = seq.value_counts()
        return entropy(seq, base=LOG_BASE)


################################################################################
# Read in input and Compute entropies
################################################################################
df = pd.read_csv(i_csv)

# E6 calculations
e6_encoder = partial(_map_to_classes, encodeMap=E6)
df["E6_alignments"] = df["alignments"].apply(e6_encoder)
df["E6"] = df["E6_alignments"].apply(_entropy)

# E20 calculations
E20_encoder = partial(_map_to_classes, encodeMap=E20)
df["E20_alignments"] = df["alignments"].apply(E20_encoder)
df["E20"] = df["E20_alignments"].apply(_entropy)


################################################################################
# Write to file
################################################################################
df.to_csv(o_csv)

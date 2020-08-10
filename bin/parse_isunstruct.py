#!/usr/bin/env python
# Parse isunstruct iul format to csv

import sys


import pandas as pd

i_iul = sys.argv[1]
o_csv = sys.argv[2]
################################################################################
# Parse Input file
################################################################################
# example fix width line
#   1 M U P 1.000
#0123456789.123456789.
colspecs = [(0, 4), (5, 6), (11, 16)]
df = pd.read_fwf(i_iul,
                colspecs = colspecs,
                names=["query_index", "Residue", "isunstruct"],
                delimiter=" ",
                skiprows = 4) # always 4 lines of header information

################################################################################
# Write std
################################################################################
df = df.set_index("query_index")
df.to_csv(o_csv)

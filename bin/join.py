#!/usr/bin/env python
################################################################################
# Joins files based on query_index index column
# Any joined csv MUST include a query_index column
################################################################################

import sys

import pandas as pd


################################################################################
# Set input and output paths
################################################################################
csv_path_1 = sys.argv[1]
#dis_path = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/f5/17eb21af0cf08cc657eb84edc16a68/1bcp_B.csv"
csv_path_2 = sys.argv[2]
#entropy_path = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/91/bfa7ac6b2297b57401008d7d629bc3/1bcp_B_entropy.csv"
o_csv = sys.argv[3]
#iss_path = "/home/joribello/Documents/OneDrive/Research/Spring_2020_Research/dataset_prep_nf/work/5f/92200950e553d349818f24ac193db9/1bcp_B.csv"
#o_csv = sys.argv[4]

################################################################################
# Read in csvs and make each residue column unique (for quality control)
################################################################################
df_1 = pd.read_csv(csv_path_1, index_col="query_index")
df_1 = df_1.rename(columns={"Residue":"Residue_1"})
df_2 = pd.read_csv(csv_path_2, index_col="query_index")
df_2 = df_2.rename(columns={"Residue":"Residue_2"})

################################################################################
# Join on query_index
################################################################################
full_df = df_1.join([df_2])

################################################################################
# Assert that residue letters match
################################################################################
assert full_df["Residue_1"].equals(full_df["Residue_2"]) , "Fatal Error: Residue Columns Do not match!"


################################################################################
# Replace individual residue columns with one Residue Column
################################################################################
full_df["Residue"] = full_df["Residue_1"]
full_df = full_df.drop(columns=["Residue_1","Residue_2"])

################################################################################
# Write to file
################################################################################
full_df.to_csv(o_csv)

#! /usr/bin/env python
import glob
import os
import sys


import pandas as pd

i_dir = sys.argv[1]
i_csv_list = glob.glob(f"{i_dir}/*")
o_csv = sys.argv[2]

def main(filesToConcat, outputPath):
    # initate first dataframe
    full_df = None

    for i, _file in enumerate(filesToConcat):
        _id = os.path.basename(_file).split(".")[0]
        print(f"Running {i+1} of {len(filesToConcat)}. {' '*8}", end="\r")
        if isinstance(full_df, pd.DataFrame): # first dataframe
            new_df = pd.read_csv(_file, index_col=0)
            new_df["protein"] = _id
            full_df = pd.concat([full_df, new_df])

        else:
            full_df = pd.read_csv(_file, index_col=0)
            full_df["protein"] = _id

    # write to file
    full_df.to_csv(outputPath)

main(filesToConcat=i_csv_list,
     outputPath=o_csv)

#! /usr/bin/env python

import sys
import json

def _convert_to_rcsb_style(parsed_list):
    """ Convert to pdb_seqres.txt style
    e.g.
        '1yj1A:1-71' -> 1yj1_A

    """
    parsed_list = [item.split(":")[0] for item in parsed_list]
    parsed_list = [f"{''.join(list(chars)[0:4])}_{''.join(list(chars)[4:])}" for chars in parsed_list]
    return parsed_list

def main(scopFile):
    scopPdb5IDs = list()

    with open(scopFile, "r") as f:
        for line in f.readlines():
            #print(line)
            if line[0] != "#": # ignore comments
                words = line.split()
                #print(words)
                scopID, hier,hier_str, scopOLD, *scopNEW  = words
                scopNEW = "".join(scopNEW)

                # only use lines describing protein hierarchy level
                if hier == "px":
                    scopPdb5IDs.append(scopNEW)

    # convert to pdb_seqres style
    scopPdb5IDs = _convert_to_rcsb_style(scopPdb5IDs)

    return scopPdb5IDs


_ids = main(sys.argv[1])
with open(sys.argv[2], "w") as f:
        json.dump(_ids, f)

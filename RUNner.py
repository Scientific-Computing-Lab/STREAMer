import itertools
import subprocess

# Define mutually exclusive sublists of options
exclusive_options = [
    ["--noHT", "--HT"],
    ["--Socket0", "--Socket1", "--Socket0Socket1"],
    ["--Socket0DDR4", "--Socket1DDR4", "--CXLDDR4", "--Socket0DDR5", "--Socket1DDR5", "--CXLDAX", "--Socket0DDR4DAX", "--Socket1DDR4DAX", "--Socket0DDR5DAX", "--Socket1DDR5DAX", "--Socket0OptaneDAX", "--Socket1OptaneDAX"],
    ["--Close", "--Spread"],
    ["--noFT", "--FT"]
]

# DAX options and flag
dax_options = ["--CXLDAX", "--Socket0DDR4DAX", "--Socket1DDR4DAX", "--Socket0DDR5DAX", "--Socket1DDR5DAX", "--Socket0OptaneDAX", "--Socket1OptaneDAX"]
dax_flag = "--DAX_Path"

# DAX_Path options
dax_path_options = ["/mnt/pmem0", "/mnt/pmem1", "/mnt/pmem2"]

# Generate all possible permutations of mutually exclusive sublists
permutations = list(itertools.product(*exclusive_options))

# Iterate over each permutation and execute the STREAMer.py script
for perm in permutations:
    if any(option in perm for option in dax_options):
        # Add DAX_Path flag when DAX-related options are present
        for dax_path_option in dax_path_options:
            command = ["python3", "STREAMer.py"] + list(perm) + [dax_flag, dax_path_option]
            subprocess.run(command)
    else:
        command = ["python3", "STREAMer.py"] + list(perm)
        subprocess.run(command)

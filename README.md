# STREAMer
STREAMer: Benchmarking remote volatile and non-volatile memory bandwidth

## STREAMer help
```
$ python3 STREAMer.py --help
usage: STREAMer.py [-h] [--noHT | --HT]
                   [--Socket0 | --Socket1 | --Socket0Socket1]
                   [--Socket0DDR4 | --Socket1DDR4 | --CXLDDR4 | --Socket0DDR5 | --Socket1DDR5 | --CXLDAX | --Socket0DDR4DAX | --Socket1DDR4DAX | --Socket0DDR5DAX | --Socket1DDR5DAX]
                   [--Close | --Spread] [--noFT | --FT] [--DAX_Path DAX_PATH]
                   [--Arrays_Size ARRAYS_SIZE]
                   [--Cores_per_Socket CORES_PER_SOCKET]

Program Options

optional arguments:
  -h, --help            show this help message and exit
  --noHT                Disable hyperthreading
  --HT                  Enable hyperthreading
  --Socket0             Use only Socket0 cores
  --Socket1             Use only Socket1 cores
  --Socket0Socket1      Use both Socket0 and Socket1 cores
  --Socket0DDR4         Use DDR4 memory on Socket0
  --Socket1DDR4         Use DDR4 memory on Socket1
  --CXLDDR4             Use DDR4 memory with CXL
  --Socket0DDR5         Use DDR5 memory on Socket0
  --Socket1DDR5         Use DDR5 memory on Socket1
  --CXLDAX              Use DAX DDR4 memory with CXL
  --Socket0DDR4DAX      Use DAX DDR4 memory on Socket0
  --Socket1DDR4DAX      Use DAX DDR4 memory on Socket1
  --Socket0DDR5DAX      Use DAX DDR5 memory on Socket0
  --Socket1DDR5DAX      Use DAX DDR5 memory on Socket1
  --Close               Use close thread affinity
  --Spread              Use spread thread affinity
  --noFT                Disable first touch
  --FT                  Enable first touch
  --DAX_Path DAX_PATH   Path for DAX (default: {NOPATH})
  --Arrays_Size ARRAYS_SIZE
                        Specify the size of the arrays (default: 100000000)
  --Cores_per_Socket CORES_PER_SOCKET
                        Specify the number of cores per socket (default: 10)
```

## STREAMer usage example
### Example 1 - Default
In case no input is supplied, the system will generate a default that will mostly be able to execute correctly on most systems and will serve as a baseline.
```
$ python3 STREAMer.py
Hyperthreading is disabled
Using only Socket0 cores
Using DDR4 memory on Socket0
Using close thread affinity
First touch is disabled
Folder 'noHT_Socket0_Socket0DDR4_Close_noFT_NOPATH_Arrays100000000_Cores10/' has been created.
```

### Example 2
In this example, we ask to run: from thread 0 up to all possible threads, without hyperthreading; using all of the cores in the node (the two sockets); enabling access to a CXL remote memory in a DAX mode (in this case, DDR4) and place the memory there (with PMDK, given a DAX path); while also spreading evenly the threads location in the hardware (Thread Affinity); and also spread evenly the memory allocation in the hardware (First Touch). A folder is created with all of the args as its name, and inside this folder, all of the runs are executed, and results are saved.
```
$ python3 STREAMer.py --noHT --Socket0Socket1 --CXLDAX --Spread --FT --DAX_Path /mnt/pmem2
Hyperthreading is disabled
Using both Socket0 and Socket1 cores
Using DAX DDR4 memory with CXL
Using spread thread affinity
First touch is enabled
Folder 'noHT_Socket0Socket1_CXLDAX_Spread_FT_@mnt@pmem2_Arrays100000000_Cores10/' has been created.
```

### Example 3
In this example, we are changing all of the possible variables for the purpose of demonstration.
```
$ python3 STREAMer.py --noHT --Socket0Socket1 --CXLDAX --Spread --FT --DAX_Path /mnt/pmem5 --Arrays_Size 10000 --Cores_per_Socket 5
Hyperthreading is disabled
Using both Socket0 and Socket1 cores
Using DAX DDR4 memory with CXL
Using spread thread affinity
First touch is enabled
Folder 'noHT_Socket0Socket1_CXLDAX_Spread_FT_@mnt@pmem5_Arrays10000_Cores5/' has been created.
```


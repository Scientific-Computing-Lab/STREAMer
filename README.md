# STREAMer
STREAMer: Benchmarking remote volatile and non-volatile memory bandwidth

```
$ python3 STREAMer.py --help
usage: STREAMer.py [-h] [--noHT] [--HT] [--Socket0] [--Socket1]
                   [--Socket0Socket1] [--Socket0DDR4] [--Socket1DDR4]
                   [--CXLDDR4] [--Socket0DDR5] [--Socket1DDR5] [--CXLDAX]
                   [--Socket0DDR4DAX] [--Socket1DDR4DAX] [--Socket0DDR5DAX]
                   [--Socket1DDR5DAX] [--Close] [--Spread] [--noFT] [--FT]
                   [--DAX_Path DAX_PATH]

Program Options

optional arguments:
  -h, --help           show this help message and exit
  --noHT               Disable hyperthreading
  --HT                 Enable hyperthreading
  --Socket0            Use only Socket0 cores
  --Socket1            Use only Socket1 cores
  --Socket0Socket1     Use both Socket0 and Socket1 cores
  --Socket0DDR4        Use DDR4 memory on Socket0
  --Socket1DDR4        Use DDR4 memory on Socket1
  --CXLDDR4            Use DDR4 memory with CXL
  --Socket0DDR5        Use DDR5 memory on Socket0
  --Socket1DDR5        Use DDR5 memory on Socket1
  --CXLDAX             Use DAX DDR4 memory with CXL
  --Socket0DDR4DAX     Use DAX DDR4 memory on Socket0
  --Socket1DDR4DAX     Use DAX DDR4 memory on Socket1
  --Socket0DDR5DAX     Use DAX DDR5 memory on Socket0
  --Socket1DDR5DAX     Use DAX DDR5 memory on Socket1
  --Close              Use close thread affinity
  --Spread             Use spread thread affinity
  --noFT               Disable first touch
  --FT                 Enable first touch
  --DAX_Path DAX_PATH  Path for DAX
```

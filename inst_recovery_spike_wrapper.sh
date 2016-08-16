#!/bin/bash

BINARY_LOCATION=/u/project/puneet/mgottsch/eccgrp-ecc-ctrl
ISA=rv64g
N=39
K=32
ORIGINAL_MESSAGE=$1
#ERROR_PATTERN=000000000000000000000000000000110000000
ERROR_PATTERN=100000000000000100000000000000000000000
CODE_TYPE=hsiao1970
POLICY=filter-rank
TIEBREAK_POLICY=pick_first
MNEMONIC_HOTNESS_FILENAME=/u/project/puneet/mgottsch/swd_ecc_data/rv64g/disassembly/rv64g-mnemonic-hotness-export.csv
RD_HOTNESS_FILENAME=/u/project/puneet/mgottsch/swd_ecc_data/rv64g/disassembly/rv64g-rd-hotness-export.csv
VERBOSE=0

# Library paths are for running on Hoffman2
LD_PRELOAD=$GCC5/lib64/libstdc++.so.6 LD_LIBRARY_PATH=$MATLAB/bin/glnxa64:$MATLAB/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/inst_recovery $ISA $N $K $ORIGINAL_MESSAGE $ERROR_PATTERN $CODE_TYPE $POLICY $TIEBREAK_POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME $VERBOSE

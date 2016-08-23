#!/bin/bash

BINARY_LOCATION=$MWG_GIT_PATH/eccgrp-ecc-ctrl
ISA=rv64g
N=39
K=32
ORIGINAL_MESSAGE=$1
ERROR_PATTERN=000000100000000000100000000000000000000
CODE_TYPE=hsiao1970
POLICY=filter-rank-rank-sort-pick-first
MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/rv64g/program-statistics/static/rv64g-mnemonic-hotness-export.csv
RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/rv64g/program-statistics/static/rv64g-rd-hotness-export.csv
VERBOSE=1

if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
else
    MY_PRELOAD=""
fi
   
LD_PRELOAD=$MY_PRELOAD LD_LIBRARY_PATH=$MCRROOT/bin/glnxa64:$MCRROOT/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/inst_recovery $ISA $N $K $ORIGINAL_MESSAGE $ERROR_PATTERN $CODE_TYPE $POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME $VERBOSE

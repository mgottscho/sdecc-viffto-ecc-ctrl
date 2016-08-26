#!/bin/bash

BINARY_LOCATION=$1
ISA=$2
BENCHMARK=$3
N=$4
K=$5
NUM_WORDS=$6
WORDS_PER_BLOCK=$7
INPUT_FILE=$8
OUTPUT_FILE=$9
NUM_THREADS=${10}
CODE_TYPE=${11}
POLICY=${12}

if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "nanocad-server-testbed" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
fi

LD_PRELOAD=$MY_PRELOAD LD_LIBRARY_PATH=$MCRROOT/bin/glnxa64:$MCRROOT/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/swd_ecc_offline_data_heuristic_recovery $ISA $BENCHMARK $N $K $NUM_WORDS $WORDS_PER_BLOCK $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY

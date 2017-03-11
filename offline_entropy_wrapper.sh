#!/bin/bash

BINARY_LOCATION=$1
NUM_CACHELINES=$2
K=$3
WORDS_PER_BLOCK=$4
INPUT_FILE=$5
OUTPUT_FILE=$6
NUM_THREADS=$7
FILE_VERSION=$8
SYMBOL_SIZE=$9

if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "nanocad-server-testbed" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "dfm" ]]; then
    MY_PRELOAD=/usr/lib64/libstdc++.so.6 # Not working as of 9/26/2016
fi

LD_PRELOAD=$MY_PRELOAD LD_LIBRARY_PATH=$MCRROOT/bin/glnxa64:$MCRROOT/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/offline_entropy $ISA $NUM_CACHELINES $K $WORDS_PER_BLOCK $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $FILE_VERSION $SYMBOL_SIZE

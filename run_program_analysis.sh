#!/bin/bash

BINARY_LOCATION=$1
BENCHMARK=$2
K=$3
INPUT_FILE=$4
OUTPUT_FILE=$5

# Library paths are for running on Hoffman2
LD_PRELOAD=$GCC5/lib64/libstdc++.so.6 LD_LIBRARY_PATH=$MATLAB/bin/glnxa64:$MATLAB/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/analyze_static_rv64g_program_statistics $BENCHMARK $K $INPUT_FILE $OUTPUT_FILE

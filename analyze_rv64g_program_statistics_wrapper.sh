#!/bin/bash

BINARY_LOCATION=$1
BENCHMARK=$2
K=$3
INPUT_FILE=$4
OUTPUT_FILE=$5

#./extract_inst_lines_from_memdatatrace.sh $INPUT_FILE ${INPUT_FILE}.inst
#./extract_data_lines_from_memdatatrace.sh $INPUT_FILE ${INPUT_FILE}.data
#./extract_data_read_lines_from_memdatatrace.sh $INPUT_FILE ${INPUT_FILE}.data.reads
#./extract_data_write_lines_from_memdatatrace.sh $INPUT_FILE ${INPUT_FILE}.data.writes

# Library paths are for running on Hoffman2
if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
else
    MY_PRELOAD=""
fi

LD_PRELOAD=$MY_PRELOAD LD_LIBRARY_PATH=$MCRROOT/bin/glnxa64:$MCRROOT/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/analyze_rv64g_program_statistics $BENCHMARK $K ${INPUT_FILE} $OUTPUT_FILE

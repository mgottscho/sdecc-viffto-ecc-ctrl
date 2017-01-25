#!/bin/bash
# 
# Author: Mark Gottscho
# Email: mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "USAGE: ./filter_memdatatrace.sh <TARGET_DIR>"
	exit
fi

TARGET_DIR=$1

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
#SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 416.gamess 429.mcf 433.milc 434.zeusmp 435.gromacs 436.cactusADM 437.leslie3d 444.namd 445.gobmk 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar 481.wrf 482.sphinx3 483.xalancbmk 998.specrand 999.specrand" # Static
SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
###############################################################################################

for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    SOURCE_FILE="${TARGET_DIR}/spike_mem_data_trace_${SPEC_BENCHMARK}.txt" 
    ./extract_inst_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.inst &
    ./extract_data_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data &
    ./extract_data_read_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data.reads &
    ./extract_data_write_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data.writes &
    ./extract_ints_from_memdatatrace.sh ${SOURCE_FILE}.data.reads ${SOURCE_FILE}.data.reads.ints &
    ./extract_ints_from_memdatatrace.sh ${SOURCE_FILE}.data.writes ${SOURCE_FILE}.data.writes.ints &
    ./extract_floats_from_memdatatrace.sh ${SOURCE_FILE}.data.reads ${SOURCE_FILE}.data.reads.floats &
    ./extract_floats_from_memdatatrace.sh ${SOURCE_FILE}.data.writes ${SOURCE_FILE}.data.writes.floats &
done

echo "Done."

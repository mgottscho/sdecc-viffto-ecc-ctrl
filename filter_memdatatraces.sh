#!/bin/bash
# 
# Author: Mark Gottscho
# Email: mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 1 ]]; then # Bad number of arguments. 
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
AXBENCH_BENCHMARKS="fft blackscholes jpeg sobel"
###############################################################################################

BENCHMARKS=$AXBENCH_BENCHMARKS
for BENCHMARK in $BENCHMARKS; do
	echo "$BENCHMARK..."
    SOURCE_FILE="${TARGET_DIR}/spike_mem_data_trace_${BENCHMARK}.txt" 
    ./filter_single_memdatatrace.sh $SOURCE_FILE &
done

echo "Done."

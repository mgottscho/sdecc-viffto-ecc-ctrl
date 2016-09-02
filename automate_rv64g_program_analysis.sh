#!/bin/bash
#
# Author: Mark Gottscho
# mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "USAGE: ./automate_rv64g_program_analysis.sh"
	exit
fi

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
ISA=rv64g    # Set the target ISA; benchmarks must be disassembled for this as well
#SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 416.gamess 429.mcf 433.milc 434.zeusmp 435.gromacs 436.cactusADM 437.leslie3d 444.namd 445.gobmk 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar 481.wrf 482.sphinx3 483.xalancbmk 998.specrand 999.specrand" -- Dynamic -- but not all are working
SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
K=32

#INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/disassembly/linux-gnu
INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike
#OUTPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/static
OUTPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic
###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY

# Submit all the SPEC CPU2006 benchmarks
echo "Analyzing..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    #INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-instructions.txt" # For static inst traces
    INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst" # For dynamic inst traces
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-program-statistics.mat"
	./analyze_rv64g_program_statistics_wrapper.sh $PWD $SPEC_BENCHMARK $K $INPUT_FILE $OUTPUT_FILE &
done

echo "Done."

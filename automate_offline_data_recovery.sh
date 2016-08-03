#!/bin/bash
#
# Author: Mark Gottscho
# mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "No arguments allowed."
	exit
fi

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
ISA=rv64g    # Set the target ISA; benchmarks must be disassembled for this as well
#SPEC_BENCHMARKS="astar bzip2 gobmk h264ref hmmer lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999 sphinx3"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
#SPEC_BENCHMARKS="bzip2 gobmk h264ref lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
SPEC_BENCHMARKS="bzip2"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
N=72
K=64
NUM_WORDS=1000
WORDS_PER_BLOCK=8
NUM_THREADS=$(cat /proc/cpuinfo | grep ^processor | wc -l ) 
CODE_TYPE=hsiao1970
POLICY=delta
TIEBREAK_POLICY=pick_random

INPUT_DIRECTORY=~/project-puneet/swd_ecc_input/$ISA
OUTPUT_DIRECTORY=~/project-puneet/swd_ecc_output/$ISA/data-recovery/offline/$CODE_TYPE/$POLICY/$TIEBREAK_POLICY

###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY

# Submit all the SPEC CPU2006 benchmarks
echo "Running..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    INPUT_FILE="$INPUT_DIRECTORY/spike_data_mem_trace_${SPEC_BENCHMARK}_shortened.txt"
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-data-heuristic-recovery.mat"
	./swd_ecc_offline_data_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_WORDS $WORDS_PER_BLOCK $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $TIEBREAK_POLICY
done

echo "Done."

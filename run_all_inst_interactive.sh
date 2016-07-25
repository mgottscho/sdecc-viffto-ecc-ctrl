#!/bin/bash
#
# Author: Mark Gottscho
# mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "USAGE: ./run_all_inst_interactive.sh"
	exit
fi

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
ISA=rv64g    # Set the target ISA; benchmarks must be disassembled for this as well
#SPEC_BENCHMARKS="astar bzip2 gobmk h264ref hmmer lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999 sphinx3"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
SPEC_BENCHMARKS="bzip2 gobmk h264ref lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
N=39
K=32
NUM_INST=1000
NUM_THREADS=$(cat /proc/cpuinfo | grep ^processor | wc -l ) 
CODE_TYPE=hsiao1970
POLICY=filter-rank
TIEBREAK_POLICY=pick_first

INPUT_DIRECTORY=~/project-puneet/swd_ecc_input/$ISA
OUTPUT_DIRECTORY=~/project-puneet/swd_ecc_output/$ISA
###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY


# Submit all the SPEC CPU2006 benchmarks
echo "Running jobs..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-disassembly-text-section-inst.txt"
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.mat"
	./run_swd_ecc_inst.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_INST $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $TIEBREAK_POLICY
done

echo "Done."

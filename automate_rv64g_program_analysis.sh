#!/bin/bash
#
# Author: Mark Gottscho
# mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "USAGE: ./analyze_rv64g_programs.sh"
	exit
fi

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
ISA=rv64g    # Set the target ISA; benchmarks must be disassembled for this as well
SPEC_BENCHMARKS="astar bwaves bzip2 calculix dealII gamess gcc GemsFDTD gobmk h264ref hmmer lbm leslie3d libquantum mcf milc namd omnetpp perlbench povray sjeng soplex sphinx3 specrand998 specrand999 tonto wrf xalancbmk zeusmp"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
#SPEC_BENCHMARKS="bzip2 gobmk h264ref lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
K=32

INPUT_DIRECTORY=~/project-puneet/swd_ecc_input/$ISA/spike
OUTPUT_DIRECTORY=~/project-puneet/swd_ecc_output/$ISA/program-statistics
###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY


# Submit all the SPEC CPU2006 benchmarks
echo "Analyzing..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    #INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-text-section-inst.txt" # For static inst traces
    INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt" # For dynamic inst traces
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-program-statistics.mat"
	./analyze_rv64g_program_statistics_wrapper.sh $PWD $SPEC_BENCHMARK $K $INPUT_FILE $OUTPUT_FILE &
done

echo "Done."

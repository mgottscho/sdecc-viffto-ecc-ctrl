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
SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 416.gamess 429.mcf 433.milc 434.zeusmp 435.gromacs 436.cactusADM 437.leslie3d 444.namd 445.gobmk 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar 481.wrf 482.sphinx3 483.xalancbmk"
N=39
K=32
NUM_INST=1000
NUM_THREADS=$(cat /proc/cpuinfo | grep ^processor | wc -l ) 
CODE_TYPE=hsiao1970
POLICY=filter-rank
TIEBREAK_POLICY=pick_last

INPUT_DIRECTORY=~/project-eedept/swd_ecc_data/$ISA/spike
OUTPUT_DIRECTORY=~/project-eedept/swd_ecc_data/$ISA/inst-recovery/offline-dynamic/$CODE_TYPE/$POLICY/$TIEBREAK_POLICY

MNEMONIC_HOTNESS_FILENAME=~/project-eedept/swd_ecc_data/$ISA/disassembly/$ISA-mnemonic-hotness-export.csv
RD_HOTNESS_FILENAME=~/project-eedept/swd_ecc_data/$ISA/disassembly/$ISA-rd-hotness-export.csv
###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY

# Submit all the SPEC CPU2006 benchmarks
echo "Running..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    #INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-text-section-inst.txt" # For static analysis
    INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt" # For dynamic analysis
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.mat"
	./swd_ecc_offline_inst_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_INST $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $TIEBREAK_POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME > $OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.log
done

echo "Done."

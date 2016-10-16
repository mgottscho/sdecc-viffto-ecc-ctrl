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

INPUT_TYPE=dynamic
if [[ "$INPUT_TYPE" == "static" ]]; then # Static evaluation
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 416.gamess 429.mcf 433.milc 434.zeusmp 435.gromacs 436.cactusADM 437.leslie3d 444.namd 445.gobmk 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar 481.wrf 482.sphinx3 483.xalancbmk" # Static -- all are working
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/disassembly/linux-gnu # For static
    MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/static/$ISA-mnemonic-hotness-static-all.csv
    RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/static/$ISA-rd-hotness-static-all.csv

elif [[ "$INPUT_TYPE" == "dynamic-static-side-info" ]]; then # Dynamic evaluation with static side info
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike # For dynamic
    MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/static/$ISA-mnemonic-hotness-static-all.csv
    RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/static/$ISA-rd-hotness-static-all.csv

elif [[ "$INPUT_TYPE" == "dynamic" ]]; then # Dynamic
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike # For dynamic
    #MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-mnemonic-hotness-dyn-all.csv
    MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-joint-mnemonic-reg-hotness-dyn-all.csv
    RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-rd-hotness-dyn-all.csv

elif [[ "$INPUT_TYPE" == "dynamic-split-int-float" ]]; then # Dynamic
    INT_SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 456.hmmer 458.sjeng 462.libquantum 464.h264ref 471.omnetpp 473.astar"
    FLOAT_SPEC_BENCHMARKS="410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 459.GemsFDTD 465.tonto 470.lbm"
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike # For dynamic
    #INT_MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-mnemonic-hotness-dyn-int.csv
    INT_MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-joint-mnemonic-reg-hotness-dyn-int.csv
    INT_RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-rd-hotness-dyn-int.csv
    #FLOAT_MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-mnemonic-hotness-dyn-flt.csv
    FLOAT_MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-joint-mnemonic-reg-hotness-dyn-float.csv
    FLOAT_RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-rd-hotness-dyn-flt.csv

elif [[ "$INPUT_TYPE" == "dynamic-perfect" ]]; then # Dynamic
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike # For dynamic
    #MNEMONIC_HOTNESS_PREFIX=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-mnemonic-hotness-dyn
    MNEMONIC_HOTNESS_PREFIX=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-joint-mnemonic-reg-hotness-dyn
    RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-rd-hotness-dyn-all.csv # FIXME Don't use rd-based policy with dynamic-perfect SI, this is placeholder
elif [[ "$INPUT_TYPE" == "dynamic-baseline" ]]; then # Baseline, all are equally likely frequencies
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike # For dynamic
    #MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-mnemonic-hotness-dyn-baseline.csv
    MNEMONIC_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-joint-mnemonic-reg-hotness-dyn-baseline.csv
    RD_HOTNESS_FILENAME=$MWG_DATA_PATH/swd_ecc_data/$ISA/program-statistics/dynamic/$ISA-rd-hotness-dyn-baseline.csv

else
    echo "ERROR, bad INPUT_TYPE: $INPUT_TYPE"
    exit 1
fi

N=39
K=32
NUM_MESSAGES=1000
NUM_THREADS=$(cat /proc/cpuinfo | grep ^processor | wc -l ) 
CODE_TYPE=hsiao1970
#NUM_SAMPLED_ERROR_PATTERNS=1000
NUM_SAMPLED_ERROR_PATTERNS=741 # Max for (39,32) SECDED
#NUM_SAMPLED_ERROR_PATTERNS=2556 # Max for (72,64) SECDED
#NUM_SAMPLED_ERROR_PATTERNS=14190 # Max for (45,32) DECTED
#NUM_SAMPLED_ERROR_PATTERNS=79079 # Max for (79,64) DECTED
#NUM_SAMPLED_ERROR_PATTERNS=141750 # Max for (144,128) ChipKill
POLICY=filter-joint-frequency-sort-pick-longest-pad
VERBOSE_RECOVERY=0

OUTPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/inst-recovery/offline-$INPUT_TYPE/$CODE_TYPE/$N,$K/$POLICY

#if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
#    NUM_THREADS=16 # Override above.
#    # qsub options used:
#    # -V: export environment variables from this calling script to each job
#    # -N: name the job. I made these so that each job will be uniquely identified by its benchmark running as well as the output file string ID
#    # -l: resource allocation flags for maximum time requested as well as maximum memory requested.
#    # -M: cluster username(s) to email with updates on job status
#    # -m: mailing rules for job status. b = begin, e = end, a = abort, s = suspended, n = never
#    MAX_TIME_PER_RUN=18:00:00 	# Maximum time of each script that will be invoked, HH:MM:SS. If this is exceeded, job will be killed.
#    #MAX_MEM_PER_RUN="$((600 * $NUM_THREADS))M" # Maximum memory needed per script that will be invoked. If this is exceeded, job will be killed.
#    MAX_MEM_PER_RUN="16G" # Maximum memory needed per script that will be invoked. If this is exceeded, job will be killed.
#    MAILING_LIST=mgottsch 		# List of users to email with status updates, separated by commas
#fi

###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY

# Submit all the SPEC CPU2006 benchmarks
echo "Running..."
echo ""

if [[ "$INPUT_TYPE" == "dynamic-split-int-float" ]]; then 
    for SPEC_BENCHMARK in $INT_SPEC_BENCHMARKS; do
        echo "$SPEC_BENCHMARK (int)..."
        INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
        OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.mat"
        JOB_STDOUT=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stdout
        JOB_STDERR=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stderr
        MNEMONIC_HOTNESS_FILENAME=$INT_MNEMONIC_HOTNESS_FILENAME
        RD_HOTNESS_FILENAME=$INT_RD_HOTNESS_FILENAME
        ./swd_ecc_offline_inst_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_MESSAGES $NUM_SAMPLED_ERROR_PATTERNS $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME $VERBOSE_RECOVERY > $JOB_STDOUT 2> $JOB_STDERR
    done
    
    for SPEC_BENCHMARK in $FLOAT_SPEC_BENCHMARKS; do
        echo "$SPEC_BENCHMARK (float)..."
        INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
        OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.mat"
        JOB_STDOUT=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stdout
        JOB_STDERR=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stderr
        MNEMONIC_HOTNESS_FILENAME=$FLOAT_MNEMONIC_HOTNESS_FILENAME
        RD_HOTNESS_FILENAME=$FLOAT_RD_HOTNESS_FILENAME
        ./swd_ecc_offline_inst_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_MESSAGES $NUM_SAMPLED_ERROR_PATTERNS $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME $VERBOSE_RECOVERY > $JOB_STDOUT 2> $JOB_STDERR
    done
else
    for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
        echo "$SPEC_BENCHMARK..."
        if [[ "$INPUT_TYPE" == "static" ]]; then 
            INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-instructions.txt"
        elif [[ "$INPUT_TYPE" == "dynamic-static-side-info" ]]; then 
            INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
        elif [[ "$INPUT_TYPE" == "dynamic" ]]; then 
            INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
        elif [[ "$INPUT_TYPE" == "dynamic-perfect" ]]; then
            INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
            MNEMONIC_HOTNESS_FILENAME="${MNEMONIC_HOTNESS_PREFIX}-${SPEC_BENCHMARK}.csv"
            # FIXME Don't use rd-based policy with dynamic-perfect SI, this is placeholder
        elif [[ "$INPUT_TYPE" == "dynamic-baseline" ]]; then 
            INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.inst"
        fi

        OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.mat"
        JOB_STDOUT=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stdout
        JOB_STDERR=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-inst-heuristic-recovery.stderr

        ./swd_ecc_offline_inst_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_MESSAGES $NUM_SAMPLED_ERROR_PATTERNS $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $MNEMONIC_HOTNESS_FILENAME $RD_HOTNESS_FILENAME $VERBOSE_RECOVERY > $JOB_STDOUT 2> $JOB_STDERR
    done
fi

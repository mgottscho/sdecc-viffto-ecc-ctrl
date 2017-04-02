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
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/data-snapshots
elif [[ "$INPUT_TYPE" == "dynamic" ]]; then # Dynamic
    SPEC_BENCHMARKS="400.perlbench 401.bzip2 403.gcc 410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 456.hmmer 458.sjeng 459.GemsFDTD 462.libquantum 464.h264ref 465.tonto 470.lbm 471.omnetpp 473.astar" # Dynamic -- working
    #SPEC_BENCHMARKS="410.bwaves 435.gromacs 436.cactusADM 444.namd 447.dealII 450.soplex 453.povray 454.calculix 459.GemsFDTD 465.tonto 470.lbm" # Dynamic -- working floats
    INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike_micro17 # For dynamic
    FILE_VERSION="micro17"
    #INPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/spike_cases17 # For dynamic
    #FILE_VERSION="cases17"
else
    echo "ERROR, bad INPUT_TYPE: $INPUT_TYPE"
    exit 1
fi

N=144
K=128
NUM_WORDS=1000
WORDS_PER_BLOCK=4
NUM_THREADS=$(cat /proc/cpuinfo | grep ^processor | wc -l ) 
CODE_TYPE=kaneda1982
NUM_SAMPLED_ERROR_PATTERNS=1000 # sampled
#NUM_SAMPLED_ERROR_PATTERNS=741 # Max for (39,32) SECDED
#NUM_SAMPLED_ERROR_PATTERNS=2556 # Max for (72,64) SECDED
#NUM_SAMPLED_ERROR_PATTERNS=14190 # Max for (45,32) DECTED
#NUM_SAMPLED_ERROR_PATTERNS=79079 # Max for (79,64) DECTED
#NUM_SAMPLED_ERROR_PATTERNS=141750 # Max for (144,128) ChipKill
POLICY=min-entropy8-pick-longest-run
CRASH_THRESHOLD=4.5
HASH_MODE=8
VERBOSE_RECOVERY=0

OUTPUT_DIRECTORY=$MWG_DATA_PATH/swd_ecc_data/$ISA/data-recovery/offline-$INPUT_TYPE/$CODE_TYPE/$N,$K/hash-$HASH_MODE/$POLICY/crash-threshold-$CRASH_THRESHOLD/`date -I`

#if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
#    NUM_THREADS=16 # Override above.
#    # qsub options used:
#    # -V: export environment variables from this calling script to each job
#    # -N: name the job. I made these so that each job will be uniquely identified by its benchmark running as well as the output file string ID
#    # -l: resource allocation flags for maximum time requested as well as maximum memory requested.
#    # -M: cluster username(s) to email with updates on job status
#    # -m: mailing rules for job status. b = begin, e = end, a = abort, s = suspended, n = never
#    MAX_TIME_PER_RUN=18:00:00 	# Maximum time of each script that will be invoked, HH:MM:SS. If this is exceeded, job will be killed.
#    MAX_MEM_PER_RUN="$((600 * $NUM_THREADS))M" # Maximum memory needed per script that will be invoked. If this is exceeded, job will be killed.
#    MAX_MEM_PER_RUN="16G" # Maximum memory needed per script that will be invoked. If this is exceeded, job will be killed.
#    MAILING_LIST=mgottsch 		# List of users to email with status updates, separated by commas
#fi

###############################################################################################

# Prepare directories
mkdir -p $OUTPUT_DIRECTORY

# Submit all the SPEC CPU2006 benchmarks
echo "Running..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
    if [[ "$INPUT_TYPE" == "static" ]]; then # Static evaluation
        INPUT_FILE="$INPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-data.txt" # For static analysis
        # TODO
    elif [[ "$INPUT_TYPE" == "dynamic" ]]; then # Dynamic evaluation
        INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.data.reads" # For dynamic analysis
        #INPUT_FILE="$INPUT_DIRECTORY/spike_mem_data_trace_${SPEC_BENCHMARK}.txt.data.reads.floats" # For dynamic analysis
    fi
    
    OUTPUT_FILE="$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-data-heuristic-recovery.mat"
    JOB_STDOUT=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-data-heuristic-recovery.stdout
    JOB_STDERR=$OUTPUT_DIRECTORY/${ISA}-${SPEC_BENCHMARK}-data-heuristic-recovery.stderr

#    if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
#        JOB_NAME="swdecc_datarecov_${SPEC_BENCHMARK}"
#        qsub -V -N $JOB_NAME -l h_data=$MAX_MEM_PER_RUN,time=$MAX_TIME_PER_RUN,highp -M $MAILING_LIST -o $JOB_STDOUT -e $JOB_STDERR -m as -pe shared $NUM_THREADS swd_ecc_offline_data_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_WORDS $NUM_SAMPLED_ERROR_PATTERNS $WORDS_PER_BLOCK $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $VERBOSE_RECOVERY
#    elif [[ "$MWG_MACHINE_NAME" == "nanocad-server-testbed" ]]; then
        ./swd_ecc_offline_data_heuristic_recovery_wrapper.sh $PWD $ISA $SPEC_BENCHMARK $N $K $NUM_WORDS $NUM_SAMPLED_ERROR_PATTERNS $WORDS_PER_BLOCK $INPUT_FILE $OUTPUT_FILE $NUM_THREADS $CODE_TYPE $POLICY $CRASH_THRESHOLD $VERBOSE_RECOVERY $FILE_VERSION $HASH_MODE > $JOB_STDOUT 2> $JOB_STDERR
#    fi
done

#if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
#    echo "Done submitting jobs."
#    echo "Use qstat to track job status and qdel to kill jobs."
#fi

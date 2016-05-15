#!/bin/bash
#
# Author: Mark Gottscho
# mgottscho@ucla.edu

ARGC=$# # Get number of arguments excluding arg0 (the script itself). Check for help message condition.
if [[ "$ARGC" != 0 ]]; then # Bad number of arguments. 
	echo "Author: Mark Gottscho"
	echo "mgottscho@ucla.edu"
	echo ""
	echo "USAGE: ./submit_jobs.sh"
	exit
fi

########################## FEEL FREE TO CHANGE THESE OPTIONS ##################################
ISA=mips    # Set the target ISA; benchmarks must be disassembled for this as well
SPEC_BENCHMARKS="astar bzip2 gobmk h264ref hmmer lbm libquantum mcf milc namd omnetpp perlbench povray sjeng soplex specrand998 specrand999 sphinx3"		# String of SPEC CPU2006 benchmark names to run, delimited by spaces.
NUM_INST=10000
N=39
K=32

INPUT_DIRECTORY=$PWD
ROOT_OUTPUT_DIRECTORY=~/project-puneet/swd_ecc_output
OUTPUT_DIRECTORY=$ROOT_OUTPUT_DIRECTORY/$ISA

# qsub options used:
# -V: export environment variables from this calling script to each job
# -N: name the job. I made these so that each job will be uniquely identified by its benchmark running as well as the output file string ID
# -l: resource allocation flags for maximum time requested as well as maximum memory requested.
# -M: cluster username(s) to email with updates on job status
# -m: mailing rules for job status. b = begin, e = end, a = abort
MAX_TIME_PER_RUN=23:00:00 	# Maximum time of each script that will be invoked, HH:MM:SS. If this is exceeded, job will be killed.
MAX_MEM_PER_RUN=4096M 		# Maximum memory needed per script that will be invoked. If this is exceeded, job will be killed.
MAILING_LIST=mgottsch 		# List of users to email with status updates, separated by commas

# Set up library path for MATLAB
MCRROOT=/u/local/apps/matlab/8.6
LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
export LD_LIBRARY_PATH;
###############################################################################################

# Prepare directories
mkdir $ROOT_OUTPUT_DIRECTORY
mkdir $OUTPUT_DIRECTORY


# Submit all the SPEC CPU2006 benchmarks
echo "Submitting jobs..."
echo ""
for SPEC_BENCHMARK in $SPEC_BENCHMARKS; do
	echo "$SPEC_BENCHMARK..."
	JOB_NAME="swd_ecc_inst_heuristic_recovery_${ISA}_${SPEC_BENCHMARK}"
	qsub -V -N $JOB_NAME -l h_rt=$MAX_TIME_PER_RUN,h_data=$MAX_MEM_PER_RUN -M $MAILING_LIST run_swd_ecc.sh $ISA $SPEC_BENCHMARK $NUM_INST $N $K $INPUT_DIRECTORY $OUTPUT_DIRECTORY
done

echo "Done submitting jobs."
echo "Use qstat to track job status and qdel to kill jobs."

#!/bin/bash
#
# Author: Mark Gottscho
# Email: mgottscho@ucla.edu

INPUT_FILE=$1
OUTPUT_FILE=$2
grep "FLOAT" $INPUT_FILE > $OUTPUT_FILE

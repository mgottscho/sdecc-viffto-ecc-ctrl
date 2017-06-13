#!/bin/bash
# 
# Author: Mark Gottscho
# Email: mgottscho@ucla.edu

SOURCE_FILE=$1

./extract_inst_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.inst
./extract_data_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data
./extract_data_read_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data.reads
./extract_data_write_lines_from_memdatatrace.sh $SOURCE_FILE ${SOURCE_FILE}.data.writes
./extract_ints_from_memdatatrace.sh ${SOURCE_FILE}.data.reads ${SOURCE_FILE}.data.reads.ints
./extract_ints_from_memdatatrace.sh ${SOURCE_FILE}.data.writes ${SOURCE_FILE}.data.writes.ints
./extract_floats_from_memdatatrace.sh ${SOURCE_FILE}.data.reads ${SOURCE_FILE}.data.reads.floats
./extract_floats_from_memdatatrace.sh ${SOURCE_FILE}.data.writes ${SOURCE_FILE}.data.writes.floats

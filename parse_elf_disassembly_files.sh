#!/bin/bash

# This script takes objdump disassembly and strips it into more usable colon-delimited CSV format as well as a pure instruction hex format.

INPUT_PREFIX=$1
FILE_1=$INPUT_PREFIX-disassembly.txt
FILE_2=$INPUT_PREFIX-disassembly-formatted.txt
FILE_3=$INPUT_PREFIX-instructions.txt

echo "Input file: $FILE_1"

sed -e "/Disassembly of section/d" $FILE_1 | sed -e "/^$/d" | sed -e "/>:/d" | sed -e "1d" | sed -r -e "s/\s*([0-9a-f]*:)/\1/g" | sed -r -e "s/([0-9a-f]{8})\s*/\1: /g" | sed -e "s/\t/ /g" > $FILE_2
sed -r -e "s/[0-9a-f]*: ([0-9a-f]*): .*/\1/g" $FILE_2 > $FILE_3

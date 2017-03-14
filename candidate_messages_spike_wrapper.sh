#!/bin/bash

BINARY_LOCATION=$MWG_GIT_PATH/eccgrp-ecc-ctrl
ORIGINAL_MESSAGE_BIN=$1
N=$2
K=$3
CODE_TYPE=$4
POLICY=$5
VERBOSE=0

if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "nanocad-server-testbed" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "dfm" ]]; then
    MY_PRELOAD=/app/apps.icsl/puneet/tools/gcc-5.4.0/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "mwg-desktop-ubuntuvm" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
fi

LD_PRELOAD=$MY_PRELOAD LD_LIBRARY_PATH=$MCRROOT/bin/glnxa64:$MCRROOT/runtime/glnxa64:$LD_LIBRARY_PATH $BINARY_LOCATION/candidate_messages_standalone $ORIGINAL_MESSAGE_BIN $N $K $CODE_TYPE $VERBOSE

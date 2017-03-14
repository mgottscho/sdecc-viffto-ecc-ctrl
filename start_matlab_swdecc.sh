#!/bin/bash
#
# Use this script to start MATLAB

if [[ "$MWG_MACHINE_NAME" == "hoffman" ]]; then
    MY_PRELOAD=$GCC5/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "nanocad-server-testbed" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "dfm" ]]; then
    MY_PRELOAD=/app/apps.icsl/puneet/tools/gcc-5.4.0/lib64/libstdc++.so.6
elif [[ "$MWG_MACHINE_NAME" == "mwg-desktop-ubuntuvm" ]]; then
    MY_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6
fi
LD_PRELOAD=$MY_PRELOAD matlab

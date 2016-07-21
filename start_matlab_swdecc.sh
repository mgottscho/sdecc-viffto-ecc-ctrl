#!/bin/bash
#
# Use this script to start MATLAB. This is needed because matlab will not find the necessary shared libraries for using MyRiscvDecode.mexa64.

#LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 matlab # For MWG-Desktop-UbuntuVM
LD_PRELOAD=$GCC5/lib64/libstdc++.so.6 matlab # For Hoffman2 -- not yet tested

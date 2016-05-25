#!/bin/bash
#
# Use this script to start MATLAB on MWG-Desktop-UbuntuVM. This is needed because matlab will not find the necessary shared libraries for using MyRiscvDecode.mexa64.

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libstdc++.so.6 matlab

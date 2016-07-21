#!/bin/bash

# MWG: TEMP FIXME TODO this should work on Hoffman! 7/20/2016
LD_PRELOAD=$GCC5/lib64/libstdc++.so.6 LD_LIBRARY_PATH=/u/local/apps/matlab/8.6/bin/glnxa64:/u/local/apps/matlab/8.6/runtime/glnxa64:$LD_LIBRARY_PATH ./swd_ecc_inst_heuristic_recovery riscv omnetpp 39 32 1000 ~/project-puneet/swd_ecc_input/riscv/rv64g-omnetpp-disassembly-text-section-inst.txt ~/project-puneet/swd_ecc_output/rv64g-omnetpp-inst-heuristic-recovery.mat 8 davydov1991

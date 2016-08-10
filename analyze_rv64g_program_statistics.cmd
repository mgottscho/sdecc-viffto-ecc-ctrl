#!/bin/csh -f
#  analyze_rv64g_program_statistics.cmd
#
#  UGE job for analyze_rv64g_program_statistics built Mon Aug  1 19:05:39 PDT 2016
#
#  The following items pertain to this script
#  Use current working directory
#$ -cwd
#  input           = /dev/null
#  output          = /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID
#$ -o /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID
#  error           = Merged with joblog
#$ -j y
#  The following items pertain to the user program
#  user program    = /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.m
#  arguments       = -m -R -singleCompThread -I common -I rv64g
#  program input   = Specified by user program
#  program output  = Specified by user program
#  Resources requested
#
#$ -l h_data=4096M,h_rt=1:00:00
#
#  Name of application for log
#$ -v QQAPP=mcc
#  Email address to notify
#$ -M mgottsch@mail
#  Notify at beginning and end of job
#$ -m bea
#  Job is not rerunable
#$ -r n
#
# Initialization for serial execution
#
  unalias *
  set qqversion = 
  set qqapp     = "mcc serial"
  set qqidir    = /u/project/puneet/mgottsch/eccgrp-ecc-ctrl
  set qqjob     = analyze_rv64g_program_statistics
  set qqodir    = /u/project/puneet/mgottsch/eccgrp-ecc-ctrl
  cd     /u/project/puneet/mgottsch/eccgrp-ecc-ctrl
  source /u/local/bin/qq.sge/qr.runtime
  if ($status != 0) exit (1)
#
  echo "UGE job for analyze_rv64g_program_statistics built Mon Aug  1 19:05:39 PDT 2016"
  echo ""
  echo "  analyze_rv64g_program_statistics directory:"
  echo "    "/u/project/puneet/mgottsch/eccgrp-ecc-ctrl
  echo "  Submitted to UGE:"
  echo "    "$qqsubmit
  echo "  SCRATCH directory:"
  echo "    "$qqscratch
#
  echo ""
  echo "analyze_rv64g_program_statistics started on:   "` hostname -s `
  echo "analyze_rv64g_program_statistics started at:   "` date `
  echo ""
#
# Run the user program
#
  source /u/local/Modules/default/init/modules.csh	
  module load matlab
  setenv LM_LICENSE_FILE /u/local/licenses/license.matlab
  set path = ( $path /sbin )
#
  echo mcc analyze_rv64g_program_statistics.m -m -R -singleCompThread -I common -I rv64g
requeue:
  /u/local/apps/matlab/8.6/bin/mcc analyze_rv64g_program_statistics.m -m -R -singleCompThread -I common -I rv64g
  set rc = $status
#
# if( `grep -c 'Maximum number of users' /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID` > 0 || `grep -c 'License checkout failed' /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID` > 0 ) then
  if( `grep -c 'Maximum number of users' /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID` > 0 || `grep -c 'License checkout failed' /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID` > 0 || `grep -c 'Could not check out a Compiler license' /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID` > 0 ) then
    head -n 13 /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID > /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/.$$
    echo "------------ waiting for a license. retrying mcc command." >> /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/.$$
    sleep 90
    mv /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/.$$ /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID
    goto requeue
  endif
#
  echo ""
  if( $rc != 0 || ! -e /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics ) then
    echo ============================================================
    echo ERROR: mcc.queue failed with status $rc
    echo ============================================================
  endif
#
  echo ""
  echo "analyze_rv64g_program_statistics finished at:  "` date `
#
# Cleanup after serial execution
#
  source /u/local/bin/qq.sge/qr.runtime
#
  echo "-------- /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID --------" >> /u/local/apps/queue.logs/mcc.log.serial
 if (`wc -l /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID  | awk '{print $1}'` >= 1000) then
        head -50 /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID >> /u/local/apps/queue.logs/mcc.log.serial
        echo " "  >> /u/local/apps/queue.logs/mcc.log.serial
        tail -10 /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID >> /u/local/apps/queue.logs/mcc.log.serial
  else
        cat /u/project/puneet/mgottsch/eccgrp-ecc-ctrl/analyze_rv64g_program_statistics.joblog.$JOB_ID >> /u/local/apps/queue.logs/mcc.log.serial
  endif
  exit (0)
